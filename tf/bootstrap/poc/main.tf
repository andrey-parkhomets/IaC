# State backend for one subscription. Copy this directory per additional subscription.
locals {
  subscription_id = "16311667-b599-473f-b4c6-0152bace79a0"
  location        = "polandcentral"

  # Every environment living in this subscription gets its own state container.
  # "bootstrap" holds the state of this root itself.
  environments = ["bootstrap", "dev"]

  # Atlantis data dir (plans, locks) per PR, persisted between GitHub Actions runs
  extra_containers = ["atlantis"]

  # Object IDs allowed to read/write state:
  #   you:  az ad signed-in-user show --query id -o tsv
  #   CI:   az ad sp show --id <AZURE_CLIENT_ID> --query id -o tsv
  state_contributor_principal_ids = [
    "af21bc71-df86-45fa-8358-05bbea39ad48", # andrey.parkhomets (bootstrap runs)
    "73cf8b90-cccf-4ead-9c05-62af4b2910b9", # 2ops_oidc SP (Atlantis)
  ]
}

provider "azurerm" {
  features {}
  subscription_id     = local.subscription_id
  storage_use_azuread = true
}

module "backend" {
  source = "../../../tf-modules/backend-init"

  location                        = local.location
  name_suffix                     = ["poc"]
  environments                    = local.environments
  extra_containers                = local.extra_containers
  state_contributor_principal_ids = local.state_contributor_principal_ids
}

output "backend_config" {
  value = module.backend.backend_config
}
