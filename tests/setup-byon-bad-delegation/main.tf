# Test setup helper — creates a VNet with two subnets where the function app
# subnet is deliberately NOT delegated. Used by integration tests to verify
# that the module rejects subnets without the required delegation.

resource "random_uuid" "bot_app_id" {}
resource "random_uuid" "api_app_id" {}
resource "random_uuid" "api_app_object_id" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.3"

  suffix = [var.name]
}

resource "azurerm_resource_group" "this" {
  location = "norwayeast"
  name     = module.naming.resource_group.name_unique
  tags     = {}
}

resource "azurerm_virtual_network" "vended" {
  address_space       = ["10.100.0.0/16"]
  location            = azurerm_resource_group.this.location
  name                = "${module.naming.virtual_network.name}-vended"
  resource_group_name = azurerm_resource_group.this.name
  tags                = {}
}

# Function app subnet WITHOUT delegation — this is the deliberate misconfiguration.
resource "azurerm_subnet" "func_no_delegation" {
  address_prefixes     = ["10.100.0.0/24"]
  name                 = "${module.naming.subnet.name}-func-bad"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vended.name
}

resource "azurerm_subnet" "pe" {
  address_prefixes     = ["10.100.1.0/24"]
  name                 = "${module.naming.subnet.name}-pe"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vended.name

  private_endpoint_network_policies = "Disabled"
}

# Storage data plane RBAC for the deploying identity.
data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "deployer_blob" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Storage Blob Data Owner"
}

resource "azurerm_role_assignment" "deployer_queue" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Storage Queue Data Contributor"
}

resource "azurerm_role_assignment" "deployer_table" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Storage Table Data Contributor"
}

resource "time_sleep" "rbac_propagation" {
  create_duration = "60s"

  depends_on = [
    azurerm_role_assignment.deployer_blob,
    azurerm_role_assignment.deployer_queue,
    azurerm_role_assignment.deployer_table,
  ]
}
