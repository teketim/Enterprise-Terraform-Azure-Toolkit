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
variable "hub_vnet_name" {
  description = "Name of the hub virtual network."
  type        = string
  default     = "vnet-ascend-hub-centralus-001"
}

variable "hub_address_space" {
  description = "Address space for the hub virtual network."
  type        = list(string)

  default = [
    "10.10.0.0/16"
  ]
}

variable "hub_subnets" {
  description = "Hub subnet names and address prefixes."
  type        = map(string)

  default = {
    "snet-management" = "10.10.1.0/24"
    "GatewaySubnet"   = "10.10.255.0/27"
  }
}
variable "dr_vnet_name" {
  description = "Name of the DR spoke virtual network."
  type        = string
  default     = "vnet-ascend-dr-centralus-001"
}

variable "dr_address_space" {
  description = "Address space for the DR spoke virtual network."
  type        = list(string)

  default = [
    "10.20.0.0/16"
  ]
}

variable "dr_subnets" {
  description = "DR spoke subnet names and address prefixes."
  type        = map(string)

  default = {
    "snet-application" = "10.20.1.0/24"
    "snet-data"        = "10.20.2.0/24"
    "snet-recovery"    = "10.20.3.0/24"
  }
}