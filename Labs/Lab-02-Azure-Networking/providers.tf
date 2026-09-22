terraform {
  # Defines the minimum Terraform CLI version required for this project
  required_version = ">= 1.5.0"

  # Defines the external providers Terraform needs
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"

      # Stay within the AzureRM 4.x release family
      version = "~> 4.0"
    }
  }
}

# Configure the Microsoft Azure provider
provider "azurerm" {
  features {}
}