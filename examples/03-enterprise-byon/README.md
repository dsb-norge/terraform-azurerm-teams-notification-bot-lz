# Enterprise BYON Example

Bring Your Own Network (BYON) deployment with unmanaged DNS — the primary enterprise pattern.

This example simulates an enterprise environment where network infrastructure is pre-provisioned ("vended") outside the module:

- A VNet with two subnets (function app + private endpoints) created externally
- The module receives existing subnet IDs via `network_config`
- Private endpoints are created **without** DNS zone groups (`manage_private_dns_zone_groups = false`) — central infrastructure (e.g. Azure Policy) handles DNS registration

## Usage

```bash
terraform init
terraform plan -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
terraform apply -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
```

<!-- BEGIN_TF_DOCS -->

```hcl
provider "azurerm" {
  storage_use_azuread = true

  features {}
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

    manage_private_dns_zone_groups = false
  }

  depends_on = [time_sleep.rbac_propagation]
}
```

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bot_service_name"></a> [bot\_service\_name](#output\_bot\_service\_name) | The name of the Bot Service. |
| <a name="output_function_app_hostname"></a> [function\_app\_hostname](#output\_function\_app\_hostname) | The default hostname of the Function App. |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App. |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | Map of private endpoint resource IDs. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group (passthrough from input). |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the Storage Account. |
| <a name="output_subnet_function_app_id"></a> [subnet\_function\_app\_id](#output\_subnet\_function\_app\_id) | ID of the function app VNet integration subnet. |
| <a name="output_subnet_private_endpoints_id"></a> [subnet\_private\_endpoints\_id](#output\_subnet\_private\_endpoints\_id) | ID of the private endpoints subnet. |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | ID of the VNet (null when using existing network). |
<!-- END_TF_DOCS -->