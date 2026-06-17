provider "azurerm" {
  storage_use_azuread = true

  features {
    # Allow `terraform destroy` to clean up the resource group even if Azure
    # has not finished evicting child resources. The Flex Consumption function
    # app delete returns success from ARM before the platform fully removes
    # the site, racing the RG delete. Safe for examples — these are ephemeral.
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

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

# --- Pre-provisioned network (simulating enterprise vended infrastructure) ---

resource "azurerm_virtual_network" "vended" {
  address_space       = ["10.100.0.0/16"]
  location            = azurerm_resource_group.this.location
  name                = "${module.naming.virtual_network.name}-vended"
  resource_group_name = azurerm_resource_group.this.name
  tags                = {}
}

resource "azurerm_subnet" "func" {
  address_prefixes     = ["10.100.0.0/24"]
  name                 = "${module.naming.subnet.name}-func"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vended.name

  delegation {
    name = "flex-consumption"

    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "pe" {
  address_prefixes     = ["10.100.1.0/24"]
  name                 = "${module.naming.subnet.name}-pe"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vended.name

  private_endpoint_network_policies = "Disabled"
}

# --- Pre-provisioned private DNS zones (simulating central DNS infrastructure) ---

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = {}
}

resource "azurerm_private_dns_zone" "queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = {}
}

resource "azurerm_private_dns_zone" "table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = {}
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob"
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.vended.id
  tags                  = {}
}

resource "azurerm_private_dns_zone_virtual_network_link" "queue" {
  name                  = "link-queue"
  private_dns_zone_name = azurerm_private_dns_zone.queue.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.vended.id
  tags                  = {}
}

resource "azurerm_private_dns_zone_virtual_network_link" "table" {
  name                  = "link-table"
  private_dns_zone_name = azurerm_private_dns_zone.table.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.vended.id
  tags                  = {}
}

# Storage data plane RBAC for the deploying identity.
# Required because the module sets shared_access_key_enabled = false.
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

# --- Module under test ---

module "teams_notification_bot" {
  source = "../../"

  name                = var.name
  resource_group_name = azurerm_resource_group.this.name

  bot_app_id        = var.bot_app_id
  api_app_id        = var.api_app_id
  api_app_object_id = var.api_app_object_id

  app_requirements = {}

  network_config = {
    create_network = false

    existing_subnet_function_app_id      = azurerm_subnet.func.id
    existing_subnet_private_endpoints_id = azurerm_subnet.pe.id

    manage_private_dns_zone_groups = true
    private_dns_zone_resource_ids = {
      blob  = azurerm_private_dns_zone.blob.id
      queue = azurerm_private_dns_zone.queue.id
      table = azurerm_private_dns_zone.table.id
    }
  }

  depends_on = [
    time_sleep.rbac_propagation,
    azurerm_private_dns_zone_virtual_network_link.blob,
    azurerm_private_dns_zone_virtual_network_link.queue,
    azurerm_private_dns_zone_virtual_network_link.table,
  ]
}
