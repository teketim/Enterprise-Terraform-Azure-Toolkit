<#
.SYNOPSIS
    Assesses Azure subscription readiness for Microsoft Foundry
    and AI workload administration.

.DESCRIPTION
    Performs non-destructive administrative checks for:
      - Azure subscription authentication/state
      - Microsoft Cognitive Services / Foundry provider
      - Azure Monitor provider
      - Log Analytics provider
      - AI quota visibility
      - Existing AI service resources

.NOTES
    Project: Project ASCEND
    Purpose: AI Infrastructure Administration portfolio validation
#>

[CmdletBinding()]
param (
    [string]$Location = "centralus"
)

$ErrorActionPreference = "Stop"
$Results = @()

function Add-AssessmentResult {
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
        throw ($output -join " ")
    }

    if (-not $output) {
        return $null
    }

    return ($output | ConvertFrom-Json)
}

Write-Host ""
Write-Host "==============================================="
Write-Host " Project ASCEND - AI Administration Assessment"
Write-Host "==============================================="
Write-Host ""

#
# Subscription context
#
try {
    $Account = Invoke-AzureCliJson -Arguments @(
        "account",
        "show"
    )

    if ($Account.state -eq "Enabled") {
        Add-AssessmentResult `
            -Category "Subscription" `
            -Check "Azure subscription" `
            -Status "PASS" `
            -Detail "$($Account.name) is Enabled"
    }
    else {
        Add-AssessmentResult `
            -Category "Subscription" `
            -Check "Azure subscription" `
            -Status "FAIL" `
            -Detail "Subscription state: $($Account.state)"
    }
}
catch {
    Add-AssessmentResult `
        -Category "Subscription" `
        -Check "Azure subscription" `
        -Status "FAIL" `
        -Detail $_.Exception.Message
}

#
# Azure Resource Providers
#
$RequiredProviders = @(
    @{
        Namespace = "Microsoft.CognitiveServices"
        Purpose   = "Microsoft Foundry / AI services"
    },
    @{
        Namespace = "Microsoft.Insights"
        Purpose   = "Azure Monitor and diagnostics"
    },
    @{
        Namespace = "Microsoft.OperationalInsights"
        Purpose   = "Log Analytics"
    }
)

foreach ($Provider in $RequiredProviders) {

    try {
        $ProviderState = Invoke-AzureCliJson -Arguments @(
            "provider",
            "show",
            "--namespace",
            $Provider.Namespace
        )

        if ($ProviderState.registrationState -eq "Registered") {
            Add-AssessmentResult `
                -Category "Platform" `
                -Check $Provider.Namespace `
                -Status "PASS" `
                -Detail "$($Provider.Purpose) provider is Registered"
        }
        else {
            Add-AssessmentResult `
                -Category "Platform" `
                -Check $Provider.Namespace `
                -Status "WARN" `
                -Detail "State: $($ProviderState.registrationState)"
        }
    }
    catch {
        Add-AssessmentResult `
            -Category "Platform" `
            -Check $Provider.Namespace `
            -Status "FAIL" `
            -Detail $_.Exception.Message
    }
}

#
# AI quota visibility
#
try {
    $Usage = Invoke-AzureCliJson -Arguments @(
        "cognitiveservices",
        "usage",
        "list",
        "--location",
        $Location
    )

    $UsageCount = @($Usage).Count

    Add-AssessmentResult `
        -Category "Capacity" `
        -Check "AI quota visibility" `
        -Status "PASS" `
        -Detail "Retrieved $UsageCount quota/usage records for $Location"
}
catch {
    Add-AssessmentResult `
        -Category "Capacity" `
        -Check "AI quota visibility" `
        -Status "WARN" `
        -Detail "Unable to query quota: $($_.Exception.Message)"
}

#
# Existing Cognitive Services / Foundry resources
#
try {
    $AiResources = Invoke-AzureCliJson -Arguments @(
        "cognitiveservices",
        "account",
        "list"
    )

    $ResourceCount = @($AiResources).Count

    if ($ResourceCount -gt 0) {
        Add-AssessmentResult `
            -Category "Inventory" `
            -Check "AI resources" `
            -Status "PASS" `
            -Detail "$ResourceCount existing AI resource(s) discovered"
    }
    else {
        Add-AssessmentResult `
            -Category "Inventory" `
            -Check "AI resources" `
            -Status "INFO" `
            -Detail "No AI resources deployed; architecture remains cost-safe"
    }
}
catch {
    Add-AssessmentResult `
        -Category "Inventory" `
        -Check "AI resources" `
        -Status "WARN" `
        -Detail $_.Exception.Message
}

#
# Display results
#
Write-Host ""
Write-Host "AI Administration Readiness Results"
Write-Host "-----------------------------------"

$Results | Format-Table -AutoSize

$PassCount = @($Results | Where-Object Status -eq "PASS").Count
$WarnCount = @($Results | Where-Object Status -eq "WARN").Count
$FailCount = @($Results | Where-Object Status -eq "FAIL").Count
$InfoCount = @($Results | Where-Object Status -eq "INFO").Count
$Total     = $Results.Count

Write-Host ""
Write-Host "Summary"
Write-Host "-------"
Write-Host "Total Checks : $Total"
Write-Host "Passed       : $PassCount"
Write-Host "Warnings     : $WarnCount"
Write-Host "Informational: $InfoCount"
Write-Host "Failed       : $FailCount"

if ($FailCount -eq 0) {
    Write-Host ""
    Write-Host "Azure foundation is READY for governed AI workload onboarding."
    exit 0
}
else {
    Write-Host ""
    Write-Host "AI administration foundation requires remediation."
    exit 1
}