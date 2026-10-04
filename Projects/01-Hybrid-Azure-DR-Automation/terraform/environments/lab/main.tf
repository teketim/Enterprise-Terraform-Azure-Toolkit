module "resource_group" {
  source = "../../modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
module "networking" {
  source = "../../modules/networking"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  hub_vnet_name     = var.hub_vnet_name
  hub_address_space = var.hub_address_space
  hub_subnets       = var.hub_subnets

  dr_vnet_name     = var.dr_vnet_name
  dr_address_space = var.dr_address_space
  dr_subnets       = var.dr_subnets

  tags = var.tags
}
