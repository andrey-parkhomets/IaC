# Importing the Azure naming module to ensure resources have unique CAF compliant names.
module "naming" {
  source  = "Azure/avm-utl-naming/azure"
  version = "0.3.0"
  suffix = ["api", "dev"]
}

module "resource_group" {
  source = "Azure/avm-res-resources-resourcegroup/azurerm"

  location         = var.location
  name             = module.naming.resource_group.name_unique
  enable_telemetry = var.enable_telemetry
}
