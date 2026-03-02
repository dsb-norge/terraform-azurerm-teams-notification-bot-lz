provider "azurerm" {
  features {}
  storage_use_azuread = true
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  suffix = [var.name]
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = "norwayeast"
}

module "teams_notification_bot" {
  source = "../../"

  name                = var.name
  resource_group_name = azurerm_resource_group.this.name

  bot_app_id        = var.bot_app_id
  api_app_id        = var.api_app_id
  api_app_object_id = var.api_app_object_id

  depends_on = [azurerm_resource_group.this]
}
