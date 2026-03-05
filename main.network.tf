#
# virtual network and subnets
#

# --- BYON subnet validation data sources ---
# When the caller provides existing subnets, read them via azapi to validate
# delegation and sizing. The azurerm_subnet data source does not expose delegation.

data "azapi_resource" "byon_subnet_function_app" {
  count = local.create_network ? 0 : 1

  type                   = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  resource_id            = var.network_config.existing_subnet_function_app_id
  response_export_values = ["properties.delegations", "properties.addressPrefix", "properties.addressPrefixes"]

  lifecycle {
    postcondition {
      condition = length([
        for d in try(self.output.properties.delegations, [])
        : d if try(d.properties.serviceName, "") == "Microsoft.App/environments"
      ]) > 0
      error_message = "The function app subnet must be delegated to Microsoft.App/environments (required for Flex Consumption)."
    }

    postcondition {
      condition = tonumber(split("/", try(
        self.output.properties.addressPrefix,
        try(self.output.properties.addressPrefixes[0], "10.0.0.0/32")
      ))[1]) <= 27
      error_message = "The function app subnet must be at least /27 (recommended size for Flex Consumption)."
    }
  }
}

data "azapi_resource" "byon_subnet_private_endpoints" {
  count = local.create_network ? 0 : 1

  type                   = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  resource_id            = var.network_config.existing_subnet_private_endpoints_id
  response_export_values = ["properties.delegations", "properties.addressPrefix", "properties.addressPrefixes"]

  lifecycle {
    postcondition {
      condition     = length(try(self.output.properties.delegations, [])) == 0
      error_message = "The private endpoints subnet must not have any delegation (delegated subnets cannot host private endpoints)."
    }

    postcondition {
      condition = tonumber(split("/", try(
        self.output.properties.addressPrefix,
        try(self.output.properties.addressPrefixes[0], "10.0.0.0/32")
      ))[1]) <= 28
      error_message = "The private endpoints subnet must be at least /28."
    }
  }
}

resource "azurerm_virtual_network" "bot" {
  count = local.create_network ? 1 : 0

  address_space       = var.network_config.vnet_address_space
  location            = var.location
  name                = module.naming.virtual_network.name
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

# Subnet for Function App Flex Consumption VNet integration.
# Delegation to Microsoft.App/environments is required for Flex Consumption.
# /27 is the recommended minimum size (supports up to 1,000 instances).
resource "azurerm_subnet" "function_app" {
  count = local.create_network ? 1 : 0

  address_prefixes     = [var.network_config.subnet_function_app_prefix]
  name                 = "${module.naming.subnet.name}-func"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bot[0].name

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

# Subnet for private endpoints (storage).
# Private endpoint network policies disabled to allow PE creation.
resource "azurerm_subnet" "private_endpoints" {
  count = local.create_network ? 1 : 0

  address_prefixes     = [var.network_config.subnet_private_endpoints_prefix]
  name                 = "${module.naming.subnet.name}-pe"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bot[0].name

  private_endpoint_network_policies = "Disabled"
}
