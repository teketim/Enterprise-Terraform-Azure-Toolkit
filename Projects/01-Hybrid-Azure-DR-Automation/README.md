# Project ASCEND — Enterprise Hybrid Azure DR & AI Operations Automation

## Executive Summary

Project ASCEND is an enterprise-style Azure infrastructure engineering portfolio project demonstrating how a senior infrastructure engineer can design, automate, validate, and operate a hybrid disaster recovery foundation in Microsoft Azure.

The project combines:

- Microsoft Azure
- Terraform Infrastructure as Code
- PowerShell operational automation
- Hub-and-spoke networking
- Disaster recovery architecture
- Microsoft Foundry / AI administration readiness
- Azure quota and platform governance
- GitHub Actions CI/CD
- Cost-conscious cloud engineering

The environment models a fictional enterprise transitioning disaster recovery capabilities from an on-premises VMware / Hyper-V environment into Microsoft Azure.

This repository emphasizes not only deployment, but also **operational validation, recoverability, governance, automation, and engineering decision-making**.

---

# Project Status

**Portfolio MVP: Complete**

Current implementation includes:

- Azure Resource Group
- Hub virtual network
- DR spoke virtual network
- Five Azure subnets
- Bidirectional VNet peering
- Modular Terraform
- PowerShell DR readiness validation
- PowerShell AI administration readiness validation
- AI operations runbook
- GitHub Actions Terraform validation
- GitHub Actions PowerShell static analysis
- Successful Azure deployment validation
- Successful CI pipeline execution

---

# Business Scenario

A fictional enterprise operates VMware and Hyper-V workloads within an on-premises datacenter.

Existing recovery procedures depend heavily on local infrastructure and manual recovery processes.

The organization requires an Azure-based DR architecture capable of supporting:

- Improved resiliency
- Repeatable infrastructure deployment
- Defined recovery tiers
- Hybrid connectivity
- Application dependency planning
- Operational health validation
- AI workload governance
- Monitoring integration
- Cost control
- Automated quality validation

The objective is not simply to create Azure resources.

The objective is to demonstrate how an infrastructure engineer approaches **architecture, automation, operational stability, disaster recovery, governance, risk, and validation**.

---

# Implemented Architecture

```mermaid
flowchart LR

    subgraph OnPrem["On-Premises / Hybrid Environment"]
        HV["VMware / Hyper-V"]
        AD["Active Directory / DNS"]
        APP["Application Workloads"]
        DB["Database Workloads"]
    end

    HYBRID["VPN / ExpressRoute<br/>Architecture Concept"]

    subgraph AzureHub["Azure Hub - 10.10.0.0/16"]
        MGMT["snet-management<br/>10.10.1.0/24"]
        GW["GatewaySubnet<br/>10.10.255.0/27"]
    end

    subgraph AzureDR["Azure DR Spoke - 10.20.0.0/16"]
        APPSUB["snet-application<br/>10.20.1.0/24"]
        DATASUB["snet-data<br/>10.20.2.0/24"]
        RECSUB["snet-recovery<br/>10.20.3.0/24"]
    end

    HV --> HYBRID
    AD --> HYBRID
    APP --> HYBRID
    DB --> HYBRID

    HYBRID -. Future Connectivity .-> GW

    AzureHub <-->|Bidirectional VNet Peering| AzureDR