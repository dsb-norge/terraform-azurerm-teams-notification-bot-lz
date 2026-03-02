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

variable "name" {
  type = string
}

variable "location" {
  type    = string
  default = "norwayeast"
}

data "azurerm_client_config" "current" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [var.name]
}

resource "azurerm_resource_group" "test" {
  name     = module.naming.resource_group.name_unique
  location = var.location
}

resource "azurerm_role_assignment" "deployer_blob" {
  scope                = azurerm_resource_group.test.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "deployer_queue" {
  scope                = azurerm_resource_group.test.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "deployer_table" {
  scope                = azurerm_resource_group.test.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Wait for RBAC propagation before downstream modules try storage data plane operations
resource "time_sleep" "rbac_propagation" {
  depends_on      = [azurerm_role_assignment.deployer_blob, azurerm_role_assignment.deployer_queue, azurerm_role_assignment.deployer_table]
  create_duration = "60s"
}

output "resource_group_name" {
  value      = azurerm_resource_group.test.name
  depends_on = [time_sleep.rbac_propagation]
}
