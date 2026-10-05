# Architecture Overview

## Purpose

This document describes the target architecture for the Enterprise Hybrid Azure DR & Automation project.

## Source Environment

The fictional source environment contains:

- VMware and Hyper-V virtualization platforms
- Active Directory Domain Services
- DNS
- Windows application servers
- Database servers
- File services
- Enterprise backup infrastructure

## Azure DR Target

The Azure DR target is designed around the following logical components:

- **Connectivity:** Site-to-Site VPN for the lab/reference design; ExpressRoute is documented as an enterprise alternative.
- **Network segmentation:** Hub-and-spoke topology separates shared connectivity from recovery workloads.
- **Security:** Network Security Groups restrict east/west and north/south traffic according to workload requirements.
- **Recovery:** Recovery Services Vault provides the control plane for supported backup/recovery scenarios.
- **Logging:** Log Analytics centralizes platform and workload telemetry.
- **Monitoring:** Azure Monitor provides health, alerting, and operational visibility.
- **Storage:** Azure Storage supports recovery-related platform requirements and diagnostic data.

## Recovery Sequence

The intended recovery order is dependency-aware:

1. Connectivity and core network services
2. Identity and DNS
3. Database and shared data services
4. Critical application services
5. Departmental applications
6. File and lower-priority services

The recovery sequence must be validated during DR testing rather than assumed.

## Design Decisions

### Hub-and-Spoke
A hub-and-spoke model is used because it provides a clear boundary between shared connectivity/security services and protected recovery workloads. It also supports future expansion without redesigning the entire address space.

### Infrastructure as Code
Terraform is used for Azure platform deployment so that infrastructure can be reviewed, version-controlled, validated, and rebuilt consistently.

### Recovery Objectives
RPO and RTO are treated as business requirements rather than arbitrary infrastructure settings. Workload owners must validate the targets before production implementation.

### Observability
Monitoring is included in the initial design. A DR platform that cannot report replication, infrastructure health, and recovery status is operationally incomplete.

## Security Considerations

- Apply least-privilege Azure RBAC.
- Restrict management traffic.
- Separate management and workload subnets where appropriate.
- Avoid embedding credentials or secrets in Terraform.
- Use managed identities/service principals for automation where supported.
- Centralize logs for recovery and security investigations.

## Validation Criteria

The architecture is considered ready for a formal DR exercise only after:

- Workload dependencies are documented.
- RPO/RTO targets are approved.
- Replication/backup health is verified.
- Network and DNS requirements are validated.
- Failover and failback procedures are documented.
- Application owners have defined functional validation steps.
- Rollback criteria are agreed upon.

## Cost-Control Note

The portfolio implementation prioritizes architecture, code quality, planning, and validation. Expensive compute resources do not need to remain deployed continuously. Terraform plans, low-cost Azure resources, sample data, and documented recovery workflows can demonstrate engineering competency while controlling lab cost.