<#
.SYNOPSIS
    Validates the Azure network foundation for the Project ASCEND
    Hybrid Azure Disaster Recovery environment.

.DESCRIPTION
    Performs operational readiness checks against the Azure resources
    deployed by Terraform.

    The script validates:
      - Resource group availability
      - Hub virtual network
      - DR spoke virtual network
      - Required hub and DR subnets
      - Bidirectional VNet peering
      - Peering connection state

.NOTES
    Project: Project ASCEND
    Purpose: GitHub portfolio / DR operational readiness validation
#>

[CmdletBinding()]
param (
    [string]$ResourceGroupName = "rg-ascend-dr-lab-centralus-001",

    [string]$HubVNetName = "vnet-ascend-hub-centralus-001",

    [string]$DrVNetName = "vnet-ascend-dr-centralus-001"
)

$ErrorActionPreference = "Stop"

$Results = @()

function Add-ReadinessResult {
    param (
        [string]$Category,
        [string]$Check,
        [string]$Status,
        [string]$Detail
    )

    $script:Results += [PSCustomObject]@{
        Category = $Category
        Check    = $Check
        Status   = $Status
        Detail   = $Detail
    }
}

function Invoke-AzureCliJson {
    param (
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $output = & az @Arguments --output json 2>&1

    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI command failed: $($output -join ' ')"
    }

    return ($output | ConvertFrom-Json)
}

Write-Host ""
Write-Host "========================================="
Write-Host " Project ASCEND - DR Readiness Assessment"
Write-Host "========================================="
Write-Host ""

#
# Azure CLI authentication check
#
try {
    $account = Invoke-AzureCliJson -Arguments @(
        "account",
        "show"
    )

    Add-ReadinessResult `
        -Category "Authentication" `
        -Check "Azure CLI authentication" `
        -Status "PASS" `
        -Detail "Authenticated to Azure subscription: $($account.name)"
}
catch {
    Add-ReadinessResult `
        -Category "Authentication" `
        -Check "Azure CLI authentication" `
        -Status "FAIL" `
        -Detail $_.Exception.Message

    $Results | Format-Table -AutoSize
    exit 1
}

#
# Resource Group
#
try {
    $resourceGroup = Invoke-AzureCliJson -Arguments @(
        "group",
        "show",
        "--name",
        $ResourceGroupName
    )

    Add-ReadinessResult `
        -Category "Foundation" `
        -Check "Resource Group" `
        -Status "PASS" `
        -Detail "$($resourceGroup.name) exists in $($resourceGroup.location)"
}
catch {
    Add-ReadinessResult `
        -Category "Foundation" `
        -Check "Resource Group" `
        -Status "FAIL" `
        -Detail "$ResourceGroupName not found"
}

#
# Hub VNet
#
try {
    $hubVnet = Invoke-AzureCliJson -Arguments @(
        "network",
        "vnet",
        "show",
        "--resource-group",
        $ResourceGroupName,
        "--name",
        $HubVNetName
    )

    Add-ReadinessResult `
        -Category "Networking" `
        -Check "Hub VNet" `
        -Status "PASS" `
        -Detail "$HubVNetName found"
}
catch {
    Add-ReadinessResult `
        -Category "Networking" `
        -Check "Hub VNet" `
        -Status "FAIL" `
        -Detail "$HubVNetName not found"
}

#
# DR VNet
#
try {
    $drVnet = Invoke-AzureCliJson -Arguments @(
        "network",
        "vnet",
        "show",
        "--resource-group",
        $ResourceGroupName,
        "--name",
        $DrVNetName
    )

    Add-ReadinessResult `
        -Category "Networking" `
        -Check "DR VNet" `
        -Status "PASS" `
        -Detail "$DrVNetName found"
}
catch {
    Add-ReadinessResult `
        -Category "Networking" `
        -Check "DR VNet" `
        -Status "FAIL" `
        -Detail "$DrVNetName not found"
}

#
# Hub subnet validation
#
$RequiredHubSubnets = @(
    "snet-management",
    "GatewaySubnet"
)

if ($hubVnet) {

    foreach ($SubnetName in $RequiredHubSubnets) {

        if ($hubVnet.subnets.name -contains $SubnetName) {

            Add-ReadinessResult `
                -Category "Networking" `
                -Check "Hub subnet: $SubnetName" `
                -Status "PASS" `
                -Detail "Subnet exists"
        }
        else {

            Add-ReadinessResult `
                -Category "Networking" `
                -Check "Hub subnet: $SubnetName" `
                -Status "FAIL" `
                -Detail "Required subnet is missing"
        }
    }
}

#
# DR subnet validation
#
$RequiredDrSubnets = @(
    "snet-application",
    "snet-data",
    "snet-recovery"
)

if ($drVnet) {

    foreach ($SubnetName in $RequiredDrSubnets) {

        if ($drVnet.subnets.name -contains $SubnetName) {

            Add-ReadinessResult `
                -Category "Networking" `
                -Check "DR subnet: $SubnetName" `
                -Status "PASS" `
                -Detail "Subnet exists"
        }
        else {

            Add-ReadinessResult `
                -Category "Networking" `
                -Check "DR subnet: $SubnetName" `
                -Status "FAIL" `
                -Detail "Required subnet is missing"
        }
    }
}

#
# Hub to DR peering
#
try {
    $hubPeerings = Invoke-AzureCliJson -Arguments @(
        "network",
        "vnet",
        "peering",
        "list",
        "--resource-group",
        $ResourceGroupName,
        "--vnet-name",
        $HubVNetName
    )

    $HubToDr = $hubPeerings |
        Where-Object { $_.name -eq "peer-hub-to-dr" }

    if ($HubToDr -and $HubToDr.peeringState -eq "Connected") {

        Add-ReadinessResult `
            -Category "Connectivity" `
            -Check "Hub to DR peering" `
            -Status "PASS" `
            -Detail "Peering state: Connected"
    }
    else {

        Add-ReadinessResult `
            -Category "Connectivity" `
            -Check "Hub to DR peering" `
            -Status "FAIL" `
            -Detail "Peering is missing or not Connected"
    }
}
catch {

    Add-ReadinessResult `
        -Category "Connectivity" `
        -Check "Hub to DR peering" `
        -Status "FAIL" `
        -Detail $_.Exception.Message
}

#
# DR to Hub peering
#
try {
    $drPeerings = Invoke-AzureCliJson -Arguments @(
        "network",
        "vnet",
        "peering",
        "list",
        "--resource-group",
        $ResourceGroupName,
        "--vnet-name",
        $DrVNetName
    )

    $DrToHub = $drPeerings |
        Where-Object { $_.name -eq "peer-dr-to-hub" }

    if ($DrToHub -and $DrToHub.peeringState -eq "Connected") {

        Add-ReadinessResult `
            -Category "Connectivity" `
            -Check "DR to Hub peering" `
            -Status "PASS" `
            -Detail "Peering state: Connected"
    }
    else {

        Add-ReadinessResult `
            -Category "Connectivity" `
            -Check "DR to Hub peering" `
            -Status "FAIL" `
            -Detail "Peering is missing or not Connected"
    }
}
catch {

    Add-ReadinessResult `
        -Category "Connectivity" `
        -Check "DR to Hub peering" `
        -Status "FAIL" `
        -Detail $_.Exception.Message
}

#
# Results
#
Write-Host ""
Write-Host "DR Readiness Results"
Write-Host "--------------------"

$Results | Format-Table -AutoSize

$PassCount = ($Results | Where-Object Status -eq "PASS").Count
$FailCount = ($Results | Where-Object Status -eq "FAIL").Count
$Total     = $Results.Count

Write-Host ""
Write-Host "Summary"
Write-Host "-------"
Write-Host "Total Checks : $Total"
Write-Host "Passed       : $PassCount"
Write-Host "Failed       : $FailCount"

if ($FailCount -eq 0) {
    Write-Host ""
    Write-Host "DR network foundation is READY."
    exit 0
}
else {
    Write-Host ""
    Write-Host "DR network foundation requires remediation."
    exit 1
}