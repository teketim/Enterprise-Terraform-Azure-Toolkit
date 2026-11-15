ARCHITECTURE & INTERVIEW MASTERY

# ARCHITECTURE & INTERVIEW MASTERY

Design decisions • Architecture walkthroughs • Troubleshooting Q&A

**Navigation:** Use GitHub's document outline or browser search.

Release 1 • Source-based edition • November 15, 2026  
Repository: <https://github.com/teketim/Enterprise-Terraform-Azure-Toolkit>

EVIDENCE RULE: Source code establishes desired infrastructure; repository reports document previous results; neither guarantees the Azure resources are presently deployed. All procedural commands are examples to review before executing.

## Executive architecture story | what this project represents

Project ASCEND models a fictional company moving away from datacenter-only recovery toward an Azure-based disaster-recovery foundation. Its code creates the repeatable platform network skeleton. Recovery Services Vault, workload replication, monitoring, a VPN, production identity integration and security controls appear in design materials as intended extensions, not as deployed components proven by the Terraform examined here.

## System context and architecture

[Architecture diagram embedded in original HTML; available in downloadable package]

## Explain the design: six critical concepts

| Concept | How to explain it in an interview |
| --- | --- |
| Hub-and-spoke | Shared connectivity services belong in a hub; workloads can be isolated into spokes. Boundaries support policy and expansion. |
| CIDR and segmentation | The hub uses 10.10.0.0/16, DR spoke 10.20.0.0/16. Non-overlap is necessary for peering and future hybrid routing. |
| VNet peering | Two peering resources enable private Azure-to-Azure connectivity; peering does not itself create site-to-site VPN or transitive routing. |
| GatewaySubnet | Reserved for a future virtual-network gateway; the subnet does not install a gateway appliance or tunnel. |
| Infrastructure as Code | Terraform modules, variables, outputs and state make infrastructure reviewable and reproducible with change control. |
| Operational readiness | Readiness scripts check resources, but an end-to-end DR test must prove restoration, dependencies, RPO/RTO and business sign-off. |

## 30-second interview answer

"I developed Project Ascend as an enterprise-style hybrid Azure DR portfolio. I structured Terraform into resource-group and networking modules, defined a management hub and separate DR spoke with five subnets, and configured bidirectional VNet peering. I also added PowerShell readiness checks and CI validation. The design separates the platform foundation from later phases such as hybrid connectivity, workload replication and monitoring, so each stage can be verified before adding cost and complexity."

## Two-minute architecture walkthrough

"The business problem was over-reliance on on-premises infrastructure and manual DR processes. I began with recovery dependencies and the need for a repeatable Azure target. I chose hub-and-spoke networking, with the hub at 10.10.0.0/16 and a DR spoke at 10.20.0.0/16, so shared services and recovery workloads have separate address spaces. Terraform modules create the RG, VNets, five subnets and both peerings. I used subnet maps and module outputs to keep the design maintainable. For operational assurance I built a PowerShell script that calls Azure CLI, checks both VNets, expected subnets, and peerings, and reports PASS or FAIL. The sample report records 11 passes, while the longer-term architecture calls for a real VPN, storage, monitoring, workload recovery, application testing, and agreed recovery objectives. I would validate those separately before claiming DR readiness."

## Design tradeoffs and architect decisions

| Decision | Benefit | Tradeoff / follow-up |
| --- | --- | --- |
| Hub and DR spoke | Clear service boundaries, future growth | Peering costs, traffic design and policy need attention |
| Separate 10.10/16 and 10.20/16 | Expandable non-overlapping ranges | May still conflict with a real on-prem or acquisition network |
| Terraform modules | Repeatability and versioned review | State governance and import discipline are necessary |
| No running production VMs in initial MVP | Low cost and fast architecture iteration | Cannot claim workload failover or application connectivity |
| Readiness PowerShell checks | Simple, observable foundation validation | Does not validate effective NSGs, routes, DNS, recovery or RPO/RTO |

## Interview Q&A | networking and Terraform

| Question | Interview-ready answer |
| --- | --- |
| What is a VNet? | A private Azure address-space boundary for resources; subnets segment that space into distinct workload/security tiers. |
| Why hub-and-spoke? | Centralizes future connectivity and shared controls while isolating DR workloads; it also scales more cleanly than ad hoc flat networking. |
| What is VNet peering? | Private connectivity between VNets over the Azure backbone with peering objects configured in both directions. |
| Can the DR spoke route automatically through the hub to on-prem? | No. Peering is not transitive; hybrid routing needs a supported gateway or routing design and the required configuration. |
| Does GatewaySubnet mean you have a VPN? | No. It reserves address space for a gateway. No gateway resource is declared in the inspected Terraform. |
| Where are NSGs defined in this project? | They are not in the inspected Project 01 networking module; I would inventory Azure and add an approved IaC design if needed. |
| NSG versus Azure Firewall? | NSGs filter at subnet/NIC boundaries with 5-tuple rules. Azure Firewall is a managed centralized stateful network security service with additional capabilities. |
| Why use Terraform instead of portal-only builds? | Versioned, repeatable, reviewable infrastructure definitions reduce configuration drift and ease recovery and peer review. |
| What is terraform state? | Terraform’s record of the relationship between declared resources and real infrastructure; it must be protected and managed carefully. |
| What does terraform plan do? | Compares desired configuration/state/provider observations to preview changes before an apply; review replacements and destroys. |
| What does for\_each accomplish? | Creates a managed instance per map key; here each key is a subnet name and each value is its CIDR range. |
| What is the difference between validate and plan? | Validate checks configuration structure; plan evaluates actual intended changes in the chosen state/provider context. |
| What did your CI pipeline validate? | Terraform formatting/initialization/validation and PowerShell static analysis, not live Azure deployment. |
| How would you test DR? | Validate dependencies, connectivity, recovery/replication, failover, business application function, failback, and actual RPO/RTO. |
| What would you improve next? | Inventory current Azure state, implement least privilege and NSG design, add validated monitoring, then pilot hybrid connectivity and a recoverable workload. |

## Troubleshooting scenario 1 | peering unexpectedly disconnected

* Establish the symptom: what failed and since when? Check whether the two VNets exist in the expected subscription/resource group.
* Inspect peering objects in both VNets, peeringState, address spaces and last changes.
* Check Azure RBAC/provisioning errors and use Activity log rather than assuming the object is missing.
* Confirm there is no address-space overlap or unsupported routing change. Correct the minimum necessary configuration under change control.
* Re-run Test-DRReadiness.ps1 and verify the connection from each direction. A Connected peering alone does not prove workload communication.

## Troubleshooting scenario 2 | VM cannot communicate between VNets

* Start at the source VM: IP configuration, guest firewall and DNS resolution.
* Check target VM and port listening state.
* Verify peering on both sides and that each VNet has no overlapping CIDR.
* Inspect effective NSGs, UDRs and routing decisions, including any NVA; test with Network Watcher tools where available.
* Test by IP and by FQDN to separate routing/firewall from DNS issues; capture packet evidence where possible.
* Document cause, fix, verification and preventive control.

## Troubleshooting scenario 3 | Terraform proposes duplicate or replacement resources

* Confirm the intended Azure subscription and Terraform backend/state/workspace.
* Run terraform state list, terraform plan and identify each proposed create/replace/destroy.
* Compare existing Azure resource IDs with tracked Terraform addresses; do not casually apply a duplicate resource group.
* If an unmanaged resource should become IaC-managed, use a reviewed import plan with matching code/state safeguards.
* Peer-review and back up state per organizational standards; apply only an approved minimal change.

## Business recovery exercise | sample workloads

The repository includes an explicitly fictional workloads.csv with AD01 (Tier 0, 15-minute RPO / 1-hour RTO), DB01 and APP01 (Tier 1), FILE01 (Tier 2), and LEGACY01 with incomplete values. These figures are demonstration inputs for dependency and recovery prioritization, not approved production service levels.

Suggested recovery sequence: network and identity/DNS, then database, then dependent application, then lower-priority file and legacy workloads. A real company must validate recovery sequencing, application dependencies and RPO/RTO with owners before a test.

## Explain / perform / troubleshoot mastery checkpoint

| Competency | Independent demonstration standard |
| --- | --- |
| Explain | Draw both VNet CIDRs, five subnets, peering direction, missing gateway and security boundaries. |
| Perform | Open the Portal or use CLI/Az to locate every original object read-only; explain all parameters. |
| Diagnose | Explain an outage using ordered checks of identity, DNS, routing, NSG and workload state. |
| Automation | Explain modules, inputs, outputs, for\_each, state and a reviewed plan. |
| Evidence | Distinguish historical sample PASS checks from today’s live configuration. |
| Business | Describe RPO versus RTO, failover/failback, and why a network foundation alone is not full DR. |

## Company-specific bridges

| Upcoming interview | Tie-in from Project Ascend | Review separately |
| --- | --- | --- |
| Jackson National Insurance | Azure networking/ops, Terraform, validation and troubleshooting | Windows patching, VMware, Azure Local, Nutanix |
| Alterra Mountain | Identity, security design, infrastructure operations | Defender XDR, incident response, hardening |
| CDW/Momentive | VMware-source hybrid DR rationale, incident troubleshooting | Veeam and validated backup restoration |
| Northwest Federal Credit Union | Architecture, design tradeoffs, networking, RBAC and IaC | Deeper Azure production network troubleshooting |
| Sidley Austin | Architecture, change control, operational ownership | Compare final JD when scheduled |

## Evidence citations and limits

Source repository: https://github.com/teketim/Enterprise-Terraform-Azure-Toolkit; flagship project: https://github.com/teketim/Enterprise-Terraform-Azure-Toolkit/tree/main/Projects/01-Hybrid-Azure-DR-Automation. Interview narratives about actual professional projects must use separately verified resume history and should not be merged with fictional Project Ascend sample workloads.

Documentation source snapshot: November 15, 2026. Generated as an independent study reference. Validate against the live Azure subscription before operational changes.