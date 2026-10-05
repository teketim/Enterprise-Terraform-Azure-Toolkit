# AI Operations Runbook

## Purpose

This runbook defines the operational controls used to onboard and administer Microsoft Foundry / Azure AI workloads within the Project ASCEND environment.

The objective is to demonstrate how an infrastructure administrator would govern AI services with the same operational disciplines applied to enterprise infrastructure: identity, access, monitoring, capacity, cost, security, and incident response.

---

## Administrative Scope

The AI administration model covers:

- Azure subscription readiness
- Resource provider registration
- Microsoft Foundry / Cognitive Services readiness
- Azure Monitor integration
- Log Analytics readiness
- AI quota and capacity visibility
- Resource inventory
- Role-based access control
- Cost governance
- Operational validation

The lab intentionally does not deploy production AI models to avoid unnecessary consumption charges.

---

## Readiness Validation

The PowerShell script:

`powershell/Test-AIAdminReadiness.ps1`

validates the Azure foundation before AI workloads are onboarded.

Current validation checks include:

| Control | Purpose |
|---|---|
| Subscription state | Confirm Azure subscription is enabled |
| Microsoft.CognitiveServices | Confirm AI / Foundry services are available |
| Microsoft.Insights | Confirm Azure Monitor provider readiness |
| Microsoft.OperationalInsights | Confirm Log Analytics provider readiness |
| AI quota visibility | Validate administrative access to capacity information |
| AI resource inventory | Identify existing AI resources and prevent unmanaged deployment |

The current lab assessment completed with:

- 6 total checks
- 5 passed
- 0 warnings
- 0 failures
- 1 informational result
- 251 quota / usage records retrieved for Central US

---

## Identity and RBAC Model

AI workloads should use Microsoft Entra ID and Azure RBAC wherever supported.

### Administrative Separation

Recommended responsibility model:

| Role Function | Responsibility |
|---|---|
| Subscription / Platform Administrator | Subscription governance, policy, networking, provider registration |
| AI Platform Administrator | Foundry resource and project administration |
| AI Developer / User | Model, agent, and application development within approved projects |
| Security / Compliance | Access reviews, logging, policy, risk oversight |
| FinOps | Usage, quota, budget, and cost monitoring |

### Principles

- Apply least privilege.
- Avoid long-lived shared credentials.
- Prefer managed identities where supported.
- Review privileged role assignments periodically.
- Separate platform administration from workload development.
- Document exceptions.

---

## AI Workload Onboarding Process

Before approving a new AI workload:

1. Confirm the subscription is enabled.
2. Confirm required resource providers are registered.
3. Validate requested Azure region.
4. Review model availability and quota.
5. Identify expected token / capacity consumption.
6. Confirm project owner and technical owner.
7. Define required RBAC roles.
8. Confirm networking requirements.
9. Confirm monitoring and logging requirements.
10. Establish budget and cost alert thresholds.
11. Validate data classification and privacy requirements.
12. Document rollback / decommission procedures.

No workload should be treated as production-ready until these controls are reviewed.

---

## Monitoring Strategy

AI services should integrate with the broader Azure monitoring model.

Operational monitoring should include:

- Resource health
- Availability
- Request failures
- Latency
- Token / request utilization
- Quota consumption
- Authentication failures
- Administrative activity
- Diagnostic logs
- Cost anomalies

Azure Monitor and Log Analytics provide the centralized operational layer.

---

## Capacity and Quota Management

AI workload capacity is not unlimited.

Administrators should:

- Review available quota before model deployment.
- Identify regional constraints.
- Monitor capacity utilization.
- Avoid deploying workloads without sufficient quota.
- Document quota increase requests.
- Track environments that compete for shared capacity.
- Maintain headroom for critical workloads.

The Project ASCEND readiness script validates that quota information can be retrieved before workloads are approved.

---

## Cost Governance

AI workloads can generate variable consumption costs.

Required controls include:

- Azure budgets
- Cost alerts
- Resource tagging
- Workload ownership
- Environment identification
- Periodic usage review
- Removal of unused deployments
- Capacity right-sizing

Recommended tags:

```text
Environment
Project
Workload
ManagedBy
Owner
CostCenter