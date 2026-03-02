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
<!-- markdownlint-disable-file MD013 -->
<!-- markdownlint-disable-file MD033 -->
<!-- markdownlint-disable-file MD037 -->
## Requirements

No requirements.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_app_id"></a> [api\_app\_id](#input\_api\_app\_id) | Client ID of the Entra ID app registration for API authentication. | `string` | n/a | yes |
| <a name="input_api_app_object_id"></a> [api\_app\_object\_id](#input\_api\_app\_object\_id) | Object ID of the Entra ID app registration for API authentication. | `string` | n/a | yes |
| <a name="input_bot_app_id"></a> [bot\_app\_id](#input\_bot\_app\_id) | Client ID of the Entra ID app registration for Bot Framework auth. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name for all resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bot_service_name"></a> [bot\_service\_name](#output\_bot\_service\_name) | The name of the Bot Service. |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group (passthrough from input). |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_naming"></a> [naming](#module\_naming) | Azure/naming/azurerm | 0.4.2 |
| <a name="module_teams_notification_bot"></a> [teams\_notification\_bot](#module\_teams\_notification\_bot) | ../../ | n/a |
<!-- END_TF_DOCS -->
