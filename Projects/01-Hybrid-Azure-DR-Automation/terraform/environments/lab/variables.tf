variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider."
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Name of the Azure resource group for the DR lab."
  type        = string
  default     = "rg-ascend-dr-lab-centralus-001"
}

variable "location" {
  description = "Azure region used for the DR lab."
  type        = string
  default     = "centralus"
}

variable "tags" {
  description = "Common tags applied to resources in this environment."
  type        = map(string)

  default = {
    Environment = "Lab"
    Project     = "Project-ASCEND"
    Workload    = "Hybrid-DR"
    ManagedBy   = "Terraform"
    Owner       = "teketim"
  }
}
