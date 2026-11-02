# Configure AzureRM in the caller only while upgrading from a module version that used it.

data "azapi_client_config" "current" {}
