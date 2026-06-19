output "application_insights_connection_string" {
  description = "The connection string of the Application Insights instance. Null when `enable_observability = false`."
  value       = var.enable_observability ? azurerm_application_insights.bot[0].connection_string : null
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key of the Application Insights instance. Null when `enable_observability = false`."
  value       = var.enable_observability ? azurerm_application_insights.bot[0].instrumentation_key : null
  sensitive   = true
}

output "bot_service_name" {
  description = "The name of the Bot Service."
  value       = azurerm_bot_service_azure_bot.bot.name
}

output "deploy_uami_client_id" {
  description = "The client ID of the deploy user-assigned managed identity. Null when deploy_github_actions_from is empty."
  value       = length(var.deploy_github_actions_from) > 0 ? azurerm_user_assigned_identity.deploy[0].client_id : null
}

output "function_app_hostname" {
  description = "The default hostname of the Function App."
  value       = azapi_resource.bot.output.properties.defaultHostName
}

output "function_app_name" {
  description = "The name of the Function App."
  value       = azapi_resource.bot.name
}

output "infrastructure_requirements_unique_hash" {
  description = "Fingerprint of infra-relevant app requirements. Compare against a new release to detect if terraform apply is needed."
  value       = var.app_requirements.infrastructure_requirements_unique_hash
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace used by the module — either the one created here or the BYO workspace passed via `var.log_analytics_workspace_id`. Null when `enable_observability = false`."
  value       = local.log_analytics_workspace_id
}

output "private_endpoint_ids" {
  description = "Map of private endpoint resource IDs."
  value = {
    for k, pe in(
      var.network_config.manage_private_dns_zone_groups
      ? azurerm_private_endpoint.managed
      : azurerm_private_endpoint.unmanaged
    ) : k => pe.id
  }
}

output "required_outbound_fqdns" {
  description = <<-DESCRIPTION
    Set of HTTPS (TCP/443) destination FQDNs the function app needs to reach
    outbound for the bot to work. Grouped by purpose so BYON consumers can
    shape their firewall / NSG / NAT-gateway rules accordingly.

    Why this matters: the function app runs on Flex Consumption with
    `vnetRouteAllEnabled = true` (per the Microsoft docs, this is implicit
    for Flex), so EVERY outbound packet — including public-Internet
    destinations — leaves through the integrated subnet's NIC. NSGs on
    that subnet apply unconditionally; if egress is locked down,
    Bot Framework auth, Teams replies, and App Insights ingestion all
    fail silently and the bot accepts inbound /api/messages but never
    replies.

    Categories:
    - `entra_id_auth`: Microsoft Entra ID / legacy AAD token endpoints.
      Always required.
    - `bot_framework`: Bot Framework Connector auth + channel endpoints.
      Always required.
    - `teams_reply`: Service Management Bot Adapter via Azure Traffic
      Manager. Required when Teams is a target channel — the Connector
      hands `https://smba.trafficmanager.net/<region>/...` to the bot as
      `Activity.serviceUrl`. Not covered by `*.botframework.com`. Source:
      Bot Framework REST API reference, Base URI section.
    - `flex_consumption_platform`: Endpoints the underlying Container
      Apps / `Microsoft.App/environments` infrastructure needs to reach
      for managed-identity token acquisition and platform bootstrap.
      Always required. Empirically: missing these causes Flex
      Consumption's scale-controller signalling to break — queue / timer
      triggers polled once at startup then never again, messages sat in
      queue indefinitely. Fingerprint when missing: ~24 FW denies/min
      from the integration subnet to `control-<region>.identity.azure.net`
      and `<region>.login.microsoft.com`. Source: Azure Container Apps
      firewall reference (Flex Consumption uses the same delegation).
    - `self_hairpin`: The function app's own public hostnames. Required
      because the function host calls itself for SyncTriggers (registers
      trigger metadata with the platform — without it, queue/timer
      triggers never wake from scale-to-zero) and for the deployment-
      sync probe. With VNet integration the host's call to its own
      hostname hairpins out through the egress firewall before returning
      to the public front-end.
    - `application_insights_ingestion`: telemetry endpoints, only emitted
      when `enable_observability = true`. Empty list otherwise.

    For consumers who can use Azure Firewall service tags instead of FQDNs:
    `AzureActiveDirectory` covers most of `entra_id_auth`,
    `AzureMonitor` covers some Monitor endpoints but NOT App Insights
    ingestion. `AzureBotService` is the INBOUND service tag (Connector ->
    bot endpoint); it does NOT cover the bot's outbound destinations.
    Use FQDNs for the outbound rules to be safe.

    Refs:
    - https://learn.microsoft.com/azure/bot-service/bot-service-resources-faq-security?view=azure-bot-service-4.0#which-specific-urls-do-i-need-to-allowlist-in-my-corporate-firewall-to-access-bot-framework-services
    - https://learn.microsoft.com/azure/bot-service/rest-api/bot-framework-rest-connector-api-reference?view=azure-bot-service-4.0#base-uri
    - https://learn.microsoft.com/azure/azure-monitor/fundamentals/azure-monitor-network-access#outbound-traffic
    - https://learn.microsoft.com/azure/azure-functions/functions-networking-options (Flex Consumption — NSGs always apply to outbound)
    - https://learn.microsoft.com/azure/container-apps/use-azure-firewall#application-rules (Container Apps FW reference — same `Microsoft.App/environments` delegation Flex Consumption runs on; documents the managed-identity and platform-bootstrap FQDNs)
    DESCRIPTION
  value = {
    entra_id_auth = [
      "login.microsoftonline.com",
      "login.windows.net",
      "login.windows.com",
      "sts.windows.net",
    ]
    bot_framework = [
      "login.botframework.com",
      "*.botframework.com",
      "state.botframework.com",
    ]
    teams_reply = [
      "smba.trafficmanager.net",
    ]
    flex_consumption_platform = [
      # Managed-identity regional control plane + Entra ID regional variants.
      # Required for the Container Apps platform under Flex Consumption to
      # acquire UAMI tokens and run scale-controller signalling. Missing
      # these is a silent killer of scale-from-zero for non-HTTP triggers.
      "*.identity.azure.net",
      "*.login.microsoft.com",
      "*.login.microsoftonline.com",
      # Platform bootstrap binary pulls on cold start.
      "mcr.microsoft.com",
      "*.data.mcr.microsoft.com",
      "packages.aks.azure.com",
      "acs-mirror.azureedge.net",
    ]
    self_hairpin = [
      azapi_resource.bot.output.properties.defaultHostName,
      replace(azapi_resource.bot.output.properties.defaultHostName, ".azurewebsites.net", ".scm.azurewebsites.net"),
    ]
    application_insights_ingestion = var.enable_observability ? [
      "*.in.applicationinsights.azure.com",
      "dc.applicationinsights.azure.com",
      "dc.services.visualstudio.com",
      "*.livediagnostics.monitor.azure.com",
    ] : []
  }
}

output "resource_group_name" {
  description = "The name of the resource group (passthrough from input)."
  value       = var.resource_group_name
}

output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = azurerm_storage_account.bot.name
}

output "subnet_function_app_id" {
  description = "ID of the function app VNet integration subnet."
  value       = local.subnet_function_app_id
}

output "subnet_private_endpoints_id" {
  description = "ID of the private endpoints subnet."
  value       = local.subnet_private_endpoints_id
}

output "uami_client_id" {
  description = "The client ID of the bot's user-assigned managed identity."
  value       = local.bot_uami_client_id
}

output "uami_principal_id" {
  description = "The principal ID of the bot's user-assigned managed identity."
  value       = local.bot_uami_principal_id
}

output "vnet_id" {
  description = "ID of the VNet (null when using existing network)."
  value       = local.create_network ? azurerm_virtual_network.bot[0].id : null
}
