# Resource Group Module

Reusable Terraform module for creating the Azure resource group that contains the DR lab resources.

## Inputs

| Name | Type | Required | Description |
|---|---|---:|---|
| `name` | string | Yes | Resource group name |
| `location` | string | Yes | Azure region |
| `tags` | map(string) | No | Governance and cost-management tags |

## Outputs

- `id`
- `name`
- `location`

## Why use a module?

The module separates the implementation of a resource group from environment-specific values. The same module can later be reused for development, test, DR, or production environments without duplicating resource code.
