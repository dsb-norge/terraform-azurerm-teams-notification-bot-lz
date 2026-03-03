# Test setup: create a resource group and assign storage data plane roles
# to the deploying identity. This is needed because the module sets
# shared_access_key_enabled = false on the storage account.

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [var.name]
}

resource "azurerm_resource_group" "test" {
  location = var.location
  name     = module.naming.resource_group.name_unique
  tags     = { "managed-by" = "terraform-test" }
}

resource "azurerm_role_assignment" "deployer_blob" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_resource_group.test.id
  role_definition_name = "Storage Blob Data Owner"
}

resource "azurerm_role_assignment" "deployer_queue" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_resource_group.test.id
  role_definition_name = "Storage Queue Data Contributor"
}

resource "azurerm_role_assignment" "deployer_table" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_resource_group.test.id
  role_definition_name = "Storage Table Data Contributor"
}

# Wait for RBAC propagation before downstream modules try storage data plane operations
resource "time_sleep" "rbac_propagation" {
  create_duration = "60s"

  depends_on = [azurerm_role_assignment.deployer_blob, azurerm_role_assignment.deployer_queue, azurerm_role_assignment.deployer_table]
}
