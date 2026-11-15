ENGINEERING HOW-TO BIBLE

# ENGINEERING HOW-TO BIBLE

Terraform foundations • Resource groups • Azure networking • Verification

**Navigation:** Use GitHub's document outline or browser search.

Release 1 • Source-based edition • November 15, 2026  
Repository: <https://github.com/teketim/Enterprise-Terraform-Azure-Toolkit>

EVIDENCE RULE: Source code establishes desired infrastructure; repository reports document previous results; neither guarantees the Azure resources are presently deployed. All procedural commands are examples to review before executing.

## How to use this engineering manual

This is a reusable, practical runbook grounded in the original Enterprise-Terraform-Azure-Toolkit repository. Its initial scope is resource groups, Azure virtual networks and subnets, hub-to-DR peering, Terraform foundations, and non-destructive readiness validation. A secure-user, Defender, Purview and migration chapter can be added later as separately validated modules.

* Read WHAT/WHY before following HOW.
* Prefer read-only discovery before changing a live subscription.
* Follow the portal, PowerShell/Az module, Azure CLI and Terraform paths; do not mix ownership between tools without an explicit change plan.
* Capture command output, timestamp, subscription, evidence, failure, resolution and rollback.

## Chapter 1 | Original repository structure and intent

The root README distinguishes Labs (focused skills) from Projects (end-to-end engineering portfolio solutions). Lab 01 defines a single Azure resource group; Lab 02 defines one VNet and a map of subnets. Project 01 composes reusable resource-group and networking modules and adds DR operational checks.

| Source location | Role in architecture |
| --- | --- |
| Labs/Lab-01-Resource-Group | Standalone resource-group lesson with variables and outputs |
| Labs/Lab-02-Azure-Networking | Standalone VNet plus mapped subnets; it does not define peering or NSGs |
| Projects/01-Hybrid-Azure-DR-Automation/terraform/environments/lab | Root module: provider, default variables, module calls, selected outputs |
| Projects/01-Hybrid-Azure-DR-Automation/terraform/modules/networking | Two VNets, five subnets and two peering objects |
| Projects/01-Hybrid-Azure-DR-Automation/powershell | DR and AI-readiness verification scripts |

## Chapter 2 | Azure resource groups: what and why

An Azure resource group is a management container for resources that share a lifecycle, permissions, policy scope, and operational ownership. The original lab defines azurerm\_resource\_group.project\_ascend; the portfolio project uses a reusable resource-group module with location and tags.

Design decision: keep the DR lab resources grouped in rg-ascend-dr-lab-centralus-001 (Central US), with consistent Environment/Project/Workload/ManagedBy/Owner tags. Resource groups are not network security boundaries.

## Resource group — Azure Portal (illustrative deployment procedure)

* Azure Portal > Resource groups > Create. Choose the intended subscription, verify the subscription before proceeding.
* Enter Resource group: rg-ascend-dr-lab-centralus-001 and Region: Central US.
* Set tags appropriate to the project (Environment=Lab, Project=Project-ASCEND, Workload=Hybrid-DR, ManagedBy=Terraform).
* Review + create, but DO NOT create a duplicate if the group already exists. If Terraform owns the existing group, use Terraform for subsequent managed changes.
* Verify under Resource groups > select group > Overview, tags and Activity log.

## Resource group — PowerShell / Az module (read-only)

```
Connect-AzAccount
Get-AzContext | Select-Object Subscription, Tenant, Account
Get-AzResourceGroup -Name "rg-ascend-dr-lab-centralus-001" |
  Select-Object ResourceGroupName, Location, Tags
```

Connect-AzAccount obtains credentials; Get-AzContext verifies the subscription/tenant; Get-AzResourceGroup reads metadata without creating anything. If not found, verify the subscription before considering provisioning. These commands require the Az modules and suitable read permissions.

## Resource group — Azure CLI (read-only)

```
az account show --query "{name:name,id:id,state:state}" -o table
az group show --name rg-ascend-dr-lab-centralus-001 -o table
```

Expected output: the intended subscription and resource group, including its Azure region. An authorization error is not the same as a missing resource.

## Resource group — Terraform source walkthrough

```
module "resource_group" {
  source   = "../../modules/resource-group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}
```

The root module delegates creation to a child module. The module output exposes id, name, and location; the networking module consumes resource group name/location. This establishes dependency automatically. Lab 01 is a separate simpler implementation, not a declaration of the same tracked object.

## Chapter 3 | Virtual networks and CIDR planning

A VNet is a private address-space boundary for Azure resources. A subnet partitions that address space by role. The original project uses non-overlapping hub and DR ranges and reserves GatewaySubnet for a potential gateway. The presence of GatewaySubnet alone does not mean a VPN gateway was deployed.

[Architecture diagram embedded in original HTML; available in downloadable package]

| Network | Source-defined CIDR | Function |
| --- | --- | --- |
| Hub VNet | 10.10.0.0/16 | Shared services / future connectivity |
| snet-management | 10.10.1.0/24 | Hub management subnet |
| GatewaySubnet | 10.10.255.0/27 | Reserved gateway subnet; no gateway in this module |
| DR spoke VNet | 10.20.0.0/16 | DR workload network |
| snet-application | 10.20.1.0/24 | Application tier |
| snet-data | 10.20.2.0/24 | Data tier |
| snet-recovery | 10.20.3.0/24 | Recovery tier |

CIDR interpretation: /16 identifies a large address block, while /24 and /27 identify more specific subnet ranges. Confirm non-overlap with existing on-premises and future cloud networks before a real hybrid connection. Names represent architectural intent, not workload deployment.

## VNet and subnet — Azure Portal verification

* Azure Portal > Virtual networks > find vnet-ascend-hub-centralus-001. Check Overview for RG/region/address space.
* Under Settings > Subnets inspect snet-management and GatewaySubnet; note address ranges and attached services.
* Open vnet-ascend-dr-centralus-001 and inspect snet-application, snet-data, and snet-recovery.
* Under Settings > Peerings verify peer-hub-to-dr and peer-dr-to-hub; confirm each shows Connected.
* Inspect Network security groups and subnet/NIC associations separately. The main portfolio Terraform networking module does not define NSGs.

## Azure CLI read-only verification

```
RG=rg-ascend-dr-lab-centralus-001
HUB=vnet-ascend-hub-centralus-001
DR=vnet-ascend-dr-centralus-001
az network vnet show -g "$RG" -n "$HUB" \
  --query "{name:name,addressSpace:addressSpace.addressPrefixes}" -o json
az network vnet subnet list -g "$RG" --vnet-name "$HUB" \
  --query "[].{name:name,prefix:addressPrefix}" -o table
az network vnet peering list -g "$RG" --vnet-name "$HUB" \
  --query "[].{name:name,state:peeringState}" -o table
```

Variable assignments (RG/HUB/DR) reduce repeated typing in Bash-style shells. --query selects fields; -o controls output; -g means resource group; -n means name. PowerShell users should set $RG/$HUB/$DR and adapt quoting, or use the Az module below.

## PowerShell read-only verification

```
$rg = "rg-ascend-dr-lab-centralus-001"
$hub = Get-AzVirtualNetwork -ResourceGroupName $rg `
  -Name "vnet-ascend-hub-centralus-001"
$hub | Select-Object Name, Location, AddressSpace
$hub.Subnets | Select-Object Name, AddressPrefix
Get-AzVirtualNetworkPeering -ResourceGroupName $rg `
  -VirtualNetworkName $hub.Name |
  Select-Object Name, PeeringState
```

Get-AzVirtualNetwork queries the VNet and its subnets. Get-AzVirtualNetworkPeering queries local peering objects; verify the reverse direction in the DR VNet separately. The original automation uses Azure CLI wrapped by PowerShell rather than the Az cmdlets.

## Chapter 4 | Terraform: reproducible deployment and state

Terraform compares declared configuration with provider-discovered infrastructure using state. Here the AzureRM provider is constrained to 4.x and receives subscription\_id from an input variable. The main lab composes module.resource\_group and module.networking; the latter defines five subnets using for\_each and two bidirectional peerings.

```
cd Projects/01-Hybrid-Azure-DR-Automation/terraform/environments/lab
terraform version
terraform fmt -check -recursive ../../
terraform init
terraform validate
terraform state list
terraform plan -out=review.tfplan
terraform show review.tfplan
```

Run this from a trusted local checkout in the correct environment with an authorized Azure identity. init downloads provider/module dependencies; validate checks configuration; state list shows objects tracked in the configured state; plan previews changes, and show renders a saved plan. Never apply a plan before verifying the target subscription, state backend, and resources it intends to create/replace/destroy.

Review risk: the repository .gitignore covers sensitive local inputs and state. Terraform plan files and state can contain secrets even when variables are marked sensitive. Avoid committing, emailing or publishing them. Do not import existing objects or switch backends casually.

## Terraform code — network implementation

```
resource "azurerm_subnet" "dr_spoke" {
  for_each = var.dr_subnets
  name = each.key
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dr_spoke.name
  address_prefixes = [each.value]
}

resource "azurerm_virtual_network_peering" "hub_to_dr" {
  name = "peer-hub-to-dr"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.dr_spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}
```

for\_each iterates the subnet-name-to-CIDR map. each.key becomes a subnet name; each.value becomes its prefix. allow\_forwarded\_traffic allows forwarded packets to be accepted across peering when appropriate routing is configured; it does not create routing or a gateway itself.

## Chapter 5 | Operational verification and troubleshooting

The source includes powershell/Test-DRReadiness.ps1. It wraps az commands, adds PASS/FAIL rows, checks one resource group, two VNets, five named subnets, and two peering relationships. Its bundled sample report contains 11 PASS results. That sample is past documentation, not a fresh production-health check.

```
pwsh ./powershell/Test-DRReadiness.ps1 `
  -ResourceGroupName "rg-ascend-dr-lab-centralus-001" `
  -HubVNetName "vnet-ascend-hub-centralus-001" `
  -DrVNetName "vnet-ascend-dr-centralus-001"
```

| Symptom | First checks | Resolution direction |
| --- | --- | --- |
| Terraform wants to create an existing RG | az account show; terraform state list; terraform plan | Check state/workspace; do not apply duplicate creation blindly |
| Peering not Connected | Peering both VNets; address-space overlap; provisioning state | Validate both objects and supported topology; repair only after impact review |
| VM cannot reach peer VNet | DNS, source/destination NIC, effective NSGs/routes, guest firewall | Use Network Watcher if available; isolate layer by layer |
| Azure CLI 403/authorization failure | Correct tenant/subscription? Role assignment? Scope? | Use approved access process; do not mistake for missing resource |
| No gateway / no on-prem connectivity | GatewaySubnet exists but gateway/VPN not declared | Design and cost-review connection; do not assume peering equals hybrid VPN |
| DR assessment passes but DR failover untested | Check actual replication, backup, app recovery validation | Treat foundation readiness separately from end-to-end DR readiness |

## Chapter 6 | Security and rollback

* Check Azure RBAC with least privilege at the proper scope; verify administrative access before changes.
* Document NSG rules separately: no NSG objects appear in this portfolio module; avoid claiming the source enforces subnet security.
* Use approved change control and a known-good Terraform plan before modifying peering, addresses, or route tables.
* For rollback, reverse only the intended change in version-controlled configuration and preview the plan; never run terraform destroy against shared or live environments merely to reset a lab.
* After every change verify peering states, subnet inventory, application connectivity (if workloads exist), logs and cost impact.

## Next manual chapters (not yet implemented in this original project)

Secure Entra user provisioning, RBAC/Conditional Access, Defender for Cloud / Defender XDR / Purview, VM deployment, full hybrid VPN, VMware-to-Azure migration, Veeam recovery, and Azure Local remain future documentation modules. They must not be presented as completed parts of the original repository until corresponding evidence exists.

## Sources and verification trail

https://github.com/teketim/Enterprise-Terraform-Azure-Toolkit | https://github.com/teketim/Enterprise-Terraform-Azure-Toolkit/tree/main/Projects/01-Hybrid-Azure-DR-Automation | Modules and scripts under the Project 01 tree. Snapshot checked against main on November 15, 2026.

Documentation source snapshot: November 15, 2026. Generated as an independent study reference. Validate against the live Azure subscription before operational changes.