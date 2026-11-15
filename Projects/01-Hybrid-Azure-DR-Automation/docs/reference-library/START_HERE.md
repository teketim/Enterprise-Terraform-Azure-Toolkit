# Project Ascend — Enterprise Reference Library

**Release 1 — November 15, 2026**

This is the source-based documentation for the original [Enterprise Terraform Azure Toolkit](https://github.com/teketim/Enterprise-Terraform-Azure-Toolkit). It is published on a **documentation branch** for review. The original `main` branch remains unchanged.

## Read the manuals directly on GitHub (no ChatGPT downloads required)

| Manual | Read online | Downloadable source |
|---|---|---|
| Engineering How-To Bible | [GitHub-rendered manual](01_Engineering_How_To_Bible.md) | [HTML file](01_Engineering_How_To_Bible.html) |
| Implementation Journal | [GitHub-rendered journal](02_Implementation_Journal.md) | [HTML file](02_Implementation_Journal.html) |
| Architecture & Interview Mastery | [GitHub-rendered playbook](03_Architecture_Interview_Mastery.md) | [HTML file](03_Architecture_Interview_Mastery.html) |

**To study immediately:** click the **GitHub-rendered manual** links above. GitHub displays Markdown as a formatted document in your browser.

**To save HTML:** open an HTML file, choose **Raw** or **Download raw file** in GitHub, save it to your Windows computer, then open that saved file in Edge or Chrome. GitHub's code view does not render HTML as a webpage.

**To create a PDF without ChatGPT downloads:** open a GitHub-rendered manual, use the browser's Print command (`Ctrl+P`) and choose **Save as PDF**. This is a practical fallback and is not guaranteed to match the layout of the originally generated PDF.

## Verified versus unverified

- **Verified in GitHub source:** Terraform resource-group and networking modules, lab files, PowerShell DR/AI readiness scripts, workflow definition, project documentation, and sample readiness reports.
- **Reported by repository documents:** the portfolio MVP and historical readiness checks.
- **Not verified against live Azure today:** current subscription deployment, NSG associations, running workloads, hybrid gateway connectivity, failover/replication, or ongoing Defender/Purview setup.

The original networking module defines VNets, subnets and bidirectional peering. It does **not** define deployed NSG resources. No live resources were changed to prepare these manuals.

## Editorial policy

Sections labeled *illustrative* are learning procedures, not evidence that the step was historically executed. The Implementation Journal separates source-controlled evidence, reported validation, and items awaiting live re-verification. Never publish credentials, Terraform state files, secrets, or private identifiers.

## Next chapters

Secure Entra user creation and RBAC; NSG policies and diagnostic flows; Defender/Purview; Terraform troubleshooting and state; hybrid identity, VMware-to-Azure migration, and disaster recovery validation.
