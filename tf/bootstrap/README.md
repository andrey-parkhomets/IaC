# Bootstrap

One directory per subscription. Each creates a resource group, a storage account and
one state container per environment hosted in that subscription. Not run by Atlantis.

## First run

```sh
cd tf/bootstrap/poc
# add your object ID and the CI one to state_contributor_principal_ids in main.tf
terraform init
terraform apply
../../../scripts/backend-config.sh .   # writes backend.hcl here and in tf/<env>/
# uncomment `backend "azurerm" {}` in versions.tf
terraform init -migrate-state -backend-config=backend.hcl
rm terraform.tfstate*
```

Role assignments can take a few minutes to propagate before `-migrate-state` succeeds.

## Adding an environment

Add it to `environments` in `main.tf`, apply, rerun `scripts/backend-config.sh`,
then add a project for `tf/<env>` in `atlantis.yaml`.

## Adding a subscription

Copy `poc/` to a new directory, change `subscription_id`, `name_suffix` and
`environments`, and do the first run. Environment names must be unique across
subscriptions because each maps to `tf/<env>`.
If the soft delete policy definition already exists in that subscription, set
`policy_definition_exists = true` on the module.
