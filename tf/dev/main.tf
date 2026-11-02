terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.9"
    }
  }
}

# Subscription comes from ARM_SUBSCRIPTION_ID (backend.hcl via hcl-get in Atlantis)
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

output "caller" {
  value = {
    object_id       = data.azurerm_client_config.current.object_id
    subscription_id = data.azurerm_client_config.current.subscription_id
  }
}
