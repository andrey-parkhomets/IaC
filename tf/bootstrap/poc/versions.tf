terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.9"
    }
  }

  # Comment out for the very first apply in a new subscription, then:
  #   terraform init -migrate-state -backend-config=backend.hcl
  backend "azurerm" {}
}
