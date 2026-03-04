#
# azure bot service with teams channel
#

# Bot service is not supported by the naming module — hardcode prefix.
resource "azurerm_bot_service_azure_bot" "bot" {
  location                = "global"
  microsoft_app_id        = var.bot_app_id
  name                    = "bot-${var.name}"
  resource_group_name     = var.resource_group_name
  sku                     = "F0"
  endpoint                = "https://${azapi_resource.bot.output.properties.defaultHostName}${var.app_requirements.bot_service.messaging_endpoint}"
  microsoft_app_tenant_id = local.tenant_id
  microsoft_app_type      = var.app_requirements.bot_service.type
  tags                    = local.common_tags
}

resource "azurerm_bot_channel_ms_teams" "bot" {
  bot_name            = azurerm_bot_service_azure_bot.bot.name
  location            = azurerm_bot_service_azure_bot.bot.location
  resource_group_name = var.resource_group_name
}
