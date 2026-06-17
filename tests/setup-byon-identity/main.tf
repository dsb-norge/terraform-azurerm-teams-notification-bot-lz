# Test setup helper — creates a UAMI in a separate resource group to simulate
# the enterprise pattern where the identity team pre-creates the bot UAMI.

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.3"

  suffix = [var.name]
}

resource "azurerm_resource_group" "identity" {
  location = "norwayeast"
  name     = "${module.naming.resource_group.name_unique}-identity"
  tags     = {}

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_user_assigned_identity" "bot" {
  location            = azurerm_resource_group.identity.location
  name                = module.naming.user_assigned_identity.name
  resource_group_name = azurerm_resource_group.identity.name
  tags                = {}
}
