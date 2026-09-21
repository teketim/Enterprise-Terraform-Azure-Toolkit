variable "name" {
  description = "Name of the Azure resource group."
  type        = string
}

variable "location" {
  description = "Azure region where the resource group metadata is stored."
  type        = string
}

variable "tags" {
  description = "Tags applied to the resource group for governance and cost management."
  type        = map(string)
  default     = {}
}
