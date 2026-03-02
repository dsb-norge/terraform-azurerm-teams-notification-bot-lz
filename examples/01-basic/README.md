# Basic Example

Minimal deployment of the Teams Notification Bot landing zone using only required variables and defaults.

This example creates:

- A resource group (via the Azure naming module)
- The full bot landing zone with default settings (no alerts, no GitHub Actions deploy identity, no management IP rules)

## Usage

```bash
terraform init
terraform plan -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
terraform apply -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
```

<!-- BEGIN_TF_DOCS -->



```hcl
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
```
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bot_service_name"></a> [bot\_service\_name](#output\_bot\_service\_name) | The name of the Bot Service. |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group (passthrough from input). |
<!-- END_TF_DOCS -->
