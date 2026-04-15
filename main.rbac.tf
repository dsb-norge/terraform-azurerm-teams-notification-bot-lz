#
# role assignments for managed identities
#

# Bot UAMI → storage account
resource "azurerm_role_assignment" "uami_storage_blob_data_owner" {
  principal_id         = local.bot_uami_principal_id
  scope                = azurerm_storage_account.bot.id
  role_definition_name = "Storage Blob Data Owner"
}

resource "azurerm_role_assignment" "uami_storage_queue_data_contributor" {
  principal_id         = local.bot_uami_principal_id
  scope                = azurerm_storage_account.bot.id
  role_definition_name = "Storage Queue Data Contributor"
}

resource "azurerm_role_assignment" "uami_storage_table_data_contributor" {
  principal_id         = local.bot_uami_principal_id
  scope                = azurerm_storage_account.bot.id
  role_definition_name = "Storage Table Data Contributor"
}

# Deploy UAMI → function app (conditional)
resource "azurerm_role_assignment" "deploy_uami_website_contributor" {
  count = length(var.deploy_github_actions_from) > 0 ? 1 : 0

  principal_id         = azurerm_user_assigned_identity.deploy[0].principal_id
  scope                = azapi_resource.bot.id
  role_definition_name = "Website Contributor"
}

# Deploy UAMI → resource group (conditional)
resource "azurerm_role_assignment" "deploy_uami_reader" {
  count = length(var.deploy_github_actions_from) > 0 ? 1 : 0

  principal_id         = azurerm_user_assigned_identity.deploy[0].principal_id
  scope                = data.azurerm_resource_group.this.id
  role_definition_name = "Reader"
}
