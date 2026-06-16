# terraform-azurerm-teams-notification-bot-lz

Landing zone module for deploying a Teams Notification Bot on Azure. Provisions all required infrastructure: Function App (Flex Consumption), Bot Service, Storage Account, Log Analytics, Application Insights, VNet integration, and optional monitoring alerts.

## Architecture

This module deploys the following resources into an existing resource group:

| Component | Resource | Purpose |
|-----------|----------|---------|
| **Compute** | Function App (Flex Consumption, FC1) | Hosts the bot's .NET 10 isolated worker |
| **Bot Service** | Azure Bot Service (F0, SingleTenant) | Routes Teams channel traffic to the Function App |
| **Storage** | Storage Account (LRS, no shared keys) | Queue triggers, table state, deployment packages |
| **Networking** | VNet + 2 subnets | VNet integration for Function App, private endpoints |
| **Private Endpoints** | 3 PEs (blob, queue, table) | Private connectivity to storage |
| **Identity** | User-Assigned Managed Identity | Passwordless access to storage and bot auth |
| **Monitoring** | Log Analytics + App Insights + Query Pack | Observability with 15 saved diagnostic KQL queries |
| **Alerts** | Metric alerts + Action Group (optional) | Poison queue, queue backlog, and heartbeat monitoring |
| **Diagnostics** | Diagnostic settings (4) | Routes Function App and Storage logs to LAW |
| **CI/CD** | Deploy UAMI + FICs (optional) | GitHub Actions OIDC deployment identity |

## Prerequisites

- An existing Azure resource group
- Two Entra ID app registrations:
  - **Bot app** (`bot_app_id`) — for Bot Framework SingleTenant auth
  - **API app** (`api_app_id`, `api_app_object_id`) — for EasyAuth on the Function App and Action Group AAD auth

## Usage

Refer to [examples](https://github.com/dsb-norge/terraform-azurerm-teams-notification-bot-lz/tree/main/examples) for usage of module.

<!-- BEGIN_TF_DOCS -->
<!-- markdownlint-disable-file MD013 -->
<!-- markdownlint-disable-file MD033 -->
<!-- markdownlint-disable-file MD037 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.68 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.bot](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource_action.register_microsoft_app](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource_action) | resource |
| [azapi_update_resource.bot_auth_settings](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |
| [azurerm_application_insights.bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_bot_channel_ms_teams.bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bot_channel_ms_teams) | resource |
| [azurerm_bot_service_azure_bot.bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bot_service_azure_bot) | resource |
| [azurerm_federated_identity_credential.deploy_github](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_log_analytics_query_pack.bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack) | resource |
| [azurerm_log_analytics_query_pack_query.all_http_traffic_10m](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.all_http_traffic_30m](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.all_traces_by_category](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.bot_handler_activity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.bot_requests_timeline](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.errors_and_warnings](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.function_executions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.inbound_requests](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.jwt_auth_events](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.msal_token_acquisition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.msteams_count](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.outbound_http_calls](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.request_e2e_timeline](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_query_pack_query.traffic_by_channel](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack_query) | resource |
| [azurerm_log_analytics_workspace.bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_action_group.bot_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_diagnostic_setting.bot_service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.poison_queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.queue_backlog](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.storage_heartbeat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_private_dns_zone.zones](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.links](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.managed](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.unmanaged](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.deploy_uami_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.deploy_uami_website_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uami_storage_blob_data_owner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uami_storage_queue_data_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uami_storage_table_data_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_service_plan.bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_account_network_rules.bot_no_data_scanner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.deployments](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_queue.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_subnet.function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.deploy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.bot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [time_sleep.deploy_uami_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azapi_resource.byon_subnet_function_app](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource) | data source |
| [azapi_resource.byon_subnet_private_endpoints](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource) | data source |
| [azapi_resource.existing_bot](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_app_id"></a> [api\_app\_id](#input\_api\_app\_id) | Client ID of the Entra ID app registration for API authentication (EasyAuth). Must be a valid UUID. | `string` | n/a | yes |
| <a name="input_api_app_object_id"></a> [api\_app\_object\_id](#input\_api\_app\_object\_id) | Object ID of the Entra ID app registration for API authentication. Used by Azure Monitor action group AAD auth. The deploying identity must be an owner of this app registration when alert\_target\_alias is set. | `string` | n/a | yes |
| <a name="input_app_requirements"></a> [app\_requirements](#input\_app\_requirements) | App requirements declared by the function app (from app-requirements.json).<br/>Specifies infrastructure dependencies: queues, routes, runtime version, auth<br/>settings, bot service config, and required app settings.<br/><br/>Pass the requirements from the app release:<br/>  app\_requirements = jsondecode(file("app-requirements.json"))<br/><br/>Extra keys in the JSON (e.g. teams\_app\_configuration) are silently discarded<br/>by the object() type — only infrastructure-relevant fields are consumed. | <pre>object({<br/>    infrastructure_requirements_unique_hash = optional(string, "")<br/>    function_app_runtime_version            = optional(string, "10.0")<br/>    storage_account_required_queues = optional(list(string), [<br/>      "botoperations", "botoperations-poison",<br/>      "notifications", "notifications-poison"<br/>    ])<br/>    well_known_routes = optional(object({<br/>      azure_alert_webhook_receiver_endpoint = optional(string, "/api/v1/alert/{alias}")<br/>    }), {})<br/>    function_app_required_app_settings = optional(list(string), [<br/>      "ApiAppId", "APPLICATIONINSIGHTS_CONNECTION_STRING",<br/>      "AzureWebJobsStorage__blobServiceUri", "AzureWebJobsStorage__clientId",<br/>      "AzureWebJobsStorage__credential", "AzureWebJobsStorage__queueServiceUri",<br/>      "AzureWebJobsStorage__tableServiceUri", "BotAppId", "PoisonAlertAlias",<br/>      "StorageAccountName", "TenantId"<br/>    ])<br/>    bot_auth_settings = optional(object({<br/>      platform_enabled       = optional(bool, true)<br/>      require_authentication = optional(bool, false)<br/>      unauthenticated_action = optional(string, "AllowAnonymous")<br/>      identity_provider      = optional(string, "azureActiveDirectory")<br/>      required_role          = optional(string, "Notifications.Send")<br/>    }), {})<br/>    bot_service = optional(object({<br/>      type               = optional(string, "SingleTenant")<br/>      messaging_endpoint = optional(string, "/api/messages")<br/>    }), {})<br/>  })</pre> | n/a | yes |
| <a name="input_bot_app_id"></a> [bot\_app\_id](#input\_bot\_app\_id) | Client ID of the Entra ID app registration for Bot Framework auth (SingleTenant). Must be a valid UUID. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name for all resources. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the pre-existing resource group to deploy resources into. | `string` | n/a | yes |
| <a name="input_alert_target_alias"></a> [alert\_target\_alias](#input\_alert\_target\_alias) | Channel alias for alert webhook delivery. Empty string disables alert resources. | `string` | `""` | no |
| <a name="input_allowed_caller_rules"></a> [allowed\_caller\_rules](#input\_allowed\_caller\_rules) | Inbound allow-list for systems calling the function app's API endpoints<br/>(/api/v1/*). Applied ONLY to the function app's public ipSecurityRestrictions<br/>— not to SCM and not to the storage account. Each rule takes either a CIDR<br/>or a service tag (mutually exclusive).<br/><br/>Use this for:<br/>  - Known Azure services calling the API (service\_tag = "AzureCloud")<br/>  - On-prem systems with stable egress IPs (cidr = "x.x.x.x/y")<br/>  - Specific Azure VNets via their NAT gateway IPs<br/><br/>Authorization is enforced separately by EasyAuth + the 'Notifications.Send'<br/>app role — allow-listing here only controls network reachability.<br/><br/>Service tag constraint:<br/>  App Service ipSecurityRestrictions accepts a narrower set of service tags<br/>  than NSG rules. Microsoft documentation says "all publicly available<br/>  service tags are supported" but in practice regional variants (e.g.<br/>  'AzureCloud.NorwayEast') are rejected with "invalid ServiceTag".<br/><br/>  Known-working tags: AzureCloud, ActionGroup, AzureBotService.<br/>  Other tags listed as supported but unverified here: ApplicationInsightsAvailability,<br/>  AzureFrontDoor.Backend, AzureTrafficManager.<br/><br/>  This variable does NOT validate the tag value against a known list —<br/>  MS may add/remove supported tags. An invalid tag will surface at apply<br/>  time with a clear ARM error.<br/><br/>Example:<br/>  allowed\_caller\_rules = [<br/>    { name = "azure-cloud", description = "Any Azure service", service\_tag = "AzureCloud" },<br/>    { name = "onprem-monitoring", description = "On-prem monitoring egress", cidr = "203.0.113.10/32" },<br/>  ] | <pre>list(object({<br/>    name        = string<br/>    description = string<br/>    cidr        = optional(string)<br/>    service_tag = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_app_namespace"></a> [app\_namespace](#input\_app\_namespace) | Root .NET namespace of the deployed function app. Used in Log Analytics KQL queries to filter by logger category. | `string` | `"TeamsNotificationBot"` | no |
| <a name="input_create_log_analytics_workspace"></a> [create\_log\_analytics\_workspace](#input\_create\_log\_analytics\_workspace) | Whether the module should create its own Log Analytics workspace. Set to<br/>`false` when passing an existing workspace via `log_analytics_workspace_id`.<br/><br/>This is a separate variable (instead of inferring from<br/>`log_analytics_workspace_id == null`) because Terraform needs the count of<br/>the LAW resource to be known at plan time. When the BYO workspace ID is an<br/>expression depending on another resource being created in the same<br/>configuration (typical in integration tests), inferring from the id alone<br/>leaves the count undetermined at plan time and the apply fails.<br/><br/>Ignored when `enable_observability = false`. | `bool` | `true` | no |
| <a name="input_data_scanner_private_link_access"></a> [data\_scanner\_private\_link\_access](#input\_data\_scanner\_private\_link\_access) | Whether to declare the Microsoft Defender for Storage data scanner<br/>(Microsoft.Security/datascanners/storageDataScanner) as a<br/>private\_link\_access entry on the storage account's network rules.<br/><br/>Default true: declare the entry. Use in subscriptions where Defender<br/>for Storage is enabled — Azure adds this entry via its reconciliation<br/>pass anyway, and declaring it explicitly converges terraform with that<br/>state so plans stay clean.<br/><br/>Set false in subscriptions without Defender for Storage. If Defender<br/>is enabled later in such a subscription, drift will appear; flip this<br/>flag back to true to converge. | `bool` | `true` | no |
| <a name="input_deploy_github_actions_from"></a> [deploy\_github\_actions\_from](#input\_deploy\_github\_actions\_from) | Map of GitHub repositories that should get federated identity credentials for CI/CD deployment.<br/>Creates a deploy UAMI with FICs when non-empty. Keys are repository names.<br/>The GitHub organization is set via var.github\_org.<br/><br/>Available settings:<br/>  environments        : list of GitHub environments to allow access from.<br/>  branches            : list of branches to allow access from.<br/>  tags                : list of tags to allow access from.<br/>  pull\_request\_events : if true, allow access from pull request events.<br/><br/>RECOMMENDATION — prefer 'environments' over 'branches' or 'tags':<br/>  Standard FICs match the OIDC token's 'subject' claim EXACTLY (no wildcards).<br/>  Tag/branch patterns like 'v*' or 'main' that depend on wildcard matching<br/>  do NOT work without a flexible FIC + claimsMatchingExpression (preview, not<br/>  supported by azurerm provider yet).<br/><br/>  Use a GitHub environment FIC and let GitHub enforce the deployment rules:<br/>    1. Configure 'environments = ["dev"]' (or "production", etc.)<br/>    2. In the app repo: Settings > Environments > <env><br/>       - Add required reviewers (optional)<br/>       - Add deployment branch/tag policy (e.g. only tags 'app-v*')<br/>    3. Workflow declares 'environment: <env>' in its deploy job<br/><br/>  This gives standard FIC reliability + GitHub-enforced wildcard restrictions.<br/><br/>  The 'tags' field has a built-in name-sanitization for wildcards (* → 'wildcard')<br/>  to avoid Azure's FIC name validation rejecting the resource, but a wildcard<br/>  subject still won't actually match any tag push without claimsMatchingExpression. | <pre>map(object({<br/>    pull_request_events = optional(bool, false)<br/>    environments        = optional(list(string), [])<br/>    branches            = optional(list(string), [])<br/>    tags                = optional(list(string), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_observability"></a> [enable\_observability](#input\_enable\_observability) | Toggle for the observability stack: Log Analytics workspace (or BYO via<br/>`log_analytics_workspace_id`), Application Insights, the saved-query pack,<br/>diagnostic settings on every loggable resource the module creates, and the<br/>metric alerts (which additionally require `alert_target_alias`).<br/><br/>Default `true` matches the original always-on behavior. Set `false` only<br/>when telemetry is intentionally not wanted — the function app runs<br/>without it (`APPLICATIONINSIGHTS_CONNECTION_STRING` is not set, the SDK<br/>falls back to a no-op). | `bool` | `true` | no |
| <a name="input_existing_bot_uami_id"></a> [existing\_bot\_uami\_id](#input\_existing\_bot\_uami\_id) | Full resource ID of a pre-created user-assigned managed identity for the bot.<br/>When set, the module skips UAMI creation and uses the provided identity.<br/>The identity must already exist and be accessible to the deploying principal.<br/><br/>Example:<br/>  /subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-my-bot | `string` | `""` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub organization name for OIDC subject claims in deploy UAMI federated identity credentials. | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for all resources. | `string` | `"norwayeast"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Bring-your-own Log Analytics workspace. When set to a workspace resource ID,<br/>the module uses that workspace for App Insights and all diagnostic settings<br/>instead of creating its own. When `null`, the module creates a workspace in<br/>`var.resource_group_name`.<br/><br/>Ignored when `enable_observability = false`.<br/><br/>Format:<pre>/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<name></pre> | `string` | `null` | no |
| <a name="input_management_ip_rules"></a> [management\_ip\_rules](#input\_management\_ip\_rules) | CIDR ranges allowed inbound on the management/admin paths — operators and<br/>CI deploy runners. Applied to:<br/>  - the function app's public endpoint (manual /api/* smoke-testing)<br/>  - the SCM/Kudu endpoint (deployments via `func azure functionapp publish`,<br/>    live log streaming, portal debugging)<br/>  - the storage account network rules (terraform apply uploading<br/>    deployment packages)<br/><br/>This is NOT for application callers pushing messages to the API — use<br/>allowed\_caller\_rules for that. Typical use: operator VPN CIDRs and the<br/>stable egress IPs of GitHub Actions runners that deploy the function app. | <pre>list(object({<br/>    name        = string<br/>    description = string<br/>    cidr        = string<br/>  }))</pre> | `[]` | no |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | Network configuration for the module. Two modes:<br/><br/>Mode 1 — Module-managed (default):<br/>  Leave network\_config as default or set create\_network = true.<br/>  Module creates VNet, subnets, private DNS zones, and VNet links.<br/><br/>Mode 2 — Bring your own network:<br/>  Set create\_network = false and provide existing subnet IDs.<br/>  Module skips VNet/subnet/DNS zone creation entirely.<br/>  Set manage\_private\_dns\_zone\_groups = false if central infrastructure<br/>  (e.g. Azure Policy) handles private DNS registration.<br/><br/>private\_dns\_zone\_group\_name controls the name used for the zone group<br/>created on each private endpoint. Projects that coexist with CAF ALZ<br/>Azure Policy should set this to "deployedByPolicy" so the policy's<br/>group-creation step finds a matching group and skips. | <pre>object({<br/>    create_network = optional(bool, true)<br/><br/>    # Mode 1 only (ignored when create_network = false):<br/>    vnet_address_space              = optional(list(string), ["10.0.0.0/16"])<br/>    subnet_function_app_prefix      = optional(string, "10.0.0.0/24")<br/>    subnet_private_endpoints_prefix = optional(string, "10.0.1.0/24")<br/><br/>    # Mode 2 only (required when create_network = false):<br/>    existing_subnet_function_app_id      = optional(string, "")<br/>    existing_subnet_private_endpoints_id = optional(string, "")<br/><br/>    # PE DNS behavior (both modes):<br/>    manage_private_dns_zone_groups = optional(bool, true)<br/>    private_dns_zone_resource_ids  = optional(map(string), {})<br/>    private_dns_zone_group_name    = optional(string, "default")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources. Caller tags take precedence over module defaults on conflict. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | The connection string of the Application Insights instance. Null when `enable_observability = false`. |
| <a name="output_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#output\_application\_insights\_instrumentation\_key) | The instrumentation key of the Application Insights instance. Null when `enable_observability = false`. |
| <a name="output_bot_service_name"></a> [bot\_service\_name](#output\_bot\_service\_name) | The name of the Bot Service. |
| <a name="output_deploy_uami_client_id"></a> [deploy\_uami\_client\_id](#output\_deploy\_uami\_client\_id) | The client ID of the deploy user-assigned managed identity. Null when deploy\_github\_actions\_from is empty. |
| <a name="output_function_app_hostname"></a> [function\_app\_hostname](#output\_function\_app\_hostname) | The default hostname of the Function App. |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App. |
| <a name="output_infrastructure_requirements_unique_hash"></a> [infrastructure\_requirements\_unique\_hash](#output\_infrastructure\_requirements\_unique\_hash) | Fingerprint of infra-relevant app requirements. Compare against a new release to detect if terraform apply is needed. |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace used by the module — either the one created here or the BYO workspace passed via `var.log_analytics_workspace_id`. Null when `enable_observability = false`. |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | Map of private endpoint resource IDs. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group (passthrough from input). |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the Storage Account. |
| <a name="output_subnet_function_app_id"></a> [subnet\_function\_app\_id](#output\_subnet\_function\_app\_id) | ID of the function app VNet integration subnet. |
| <a name="output_subnet_private_endpoints_id"></a> [subnet\_private\_endpoints\_id](#output\_subnet\_private\_endpoints\_id) | ID of the private endpoints subnet. |
| <a name="output_uami_client_id"></a> [uami\_client\_id](#output\_uami\_client\_id) | The client ID of the bot's user-assigned managed identity. |
| <a name="output_uami_principal_id"></a> [uami\_principal\_id](#output\_uami\_principal\_id) | The principal ID of the bot's user-assigned managed identity. |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | ID of the VNet (null when using existing network). |

## Modules

No modules.
<!-- END_TF_DOCS -->
