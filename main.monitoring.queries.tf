#
# query pack - saved KQL queries for diagnostics
#

# Query packs are not supported by the naming module — hardcode prefix.
resource "azurerm_log_analytics_query_pack" "bot" {
  count = var.enable_observability ? 1 : 0

  location            = var.location
  name                = "qp-${var.name}"
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

resource "azurerm_log_analytics_query_pack_query" "msteams_count" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    ABSBotRequests
    | where Channel == "msteams"
    | count
  KQL
  display_name   = "Teams channel requests (count)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["audit"]
  description    = "Count of ABSBotRequests for msteams channel. Should be >0 if Teams is routing to Bot Service."
  resource_types = ["microsoft.botservice/botservices"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "traffic_by_channel" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    ABSBotRequests
    | summarize count() by Channel
  KQL
  display_name   = "Bot traffic by channel"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["audit"]
  description    = "Summarize ABSBotRequests by channel. Shows which channels are actively routing traffic to Bot Service."
  resource_types = ["microsoft.botservice/botservices"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "all_http_traffic_10m" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    AppRequests
    | where TimeGenerated > ago(10m)
    | project TimeGenerated, Name, Url, ResultCode, ClientIP
    | order by TimeGenerated desc
  KQL
  display_name   = "Function app HTTP traffic (last 10 min)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["applications"]
  description    = "All HTTP requests hitting the function app in the last 10 minutes."
  resource_types = ["microsoft.insights/components"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "all_http_traffic_30m" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    AppRequests
    | where TimeGenerated > ago(30m)
    | project TimeGenerated, Name, Url, ResultCode, ClientIP
    | order by TimeGenerated desc
  KQL
  display_name   = "Function app HTTP traffic (last 30 min)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["applications"]
  description    = "All HTTP requests hitting the function app over a wider window."
  resource_types = ["microsoft.insights/components"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "bot_requests_timeline" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    ABSBotRequests
    | where TimeGenerated > ago(24h)
    | project TimeGenerated, Channel, OperationName, ResultCode, DurationMs
    | order by TimeGenerated desc
  KQL
  display_name   = "Bot requests timeline (last 24h)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["audit"]
  description    = "All ABSBotRequests over the last 24 hours with channel, result code, and duration."
  resource_types = ["microsoft.botservice/botservices"]
  tags           = local.query_labels
}

#
# app-level traces — bot handler, MSAL auth, and inbound request logging
#

resource "azurerm_log_analytics_query_pack_query" "bot_handler_activity" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    AppTraces
    | where TimeGenerated > ago(1h)
    | where Properties.CategoryName == "${var.app_namespace}.Services.TeamsBotHandler"
    | project TimeGenerated, Message, SeverityLevel
    | order by TimeGenerated desc
  KQL
  display_name   = "Bot handler activity (last 1h)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["applications"]
  description    = "Messages and conversation events processed by TeamsBotHandler — install, uninstall, and inbound messages with channel info."
  resource_types = ["microsoft.insights/components"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "inbound_requests" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    AppTraces
    | where TimeGenerated > ago(1h)
    | where Properties.CategoryName == "${var.app_namespace}.Functions.BotMessagesFunction"
    | project TimeGenerated, Message, SeverityLevel
    | order by TimeGenerated desc
  KQL
  display_name   = "Inbound /api/messages requests (last 1h)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["applications"]
  description    = "All requests hitting BotMessagesFunction — shows source IP and timing."
  resource_types = ["microsoft.insights/components"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "msal_token_acquisition" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    AppTraces
    | where TimeGenerated > ago(1h)
    | where Properties.CategoryName == "Microsoft.Agents.Authentication.Msal.MsalAuth"
    | project TimeGenerated, Message = substring(Message, 0, 200), SeverityLevel
    | order by TimeGenerated desc
  KQL
  display_name   = "MSAL token acquisition (last 1h)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["applications"]
  description    = "MsalAuth debug logs — token cache hits/misses, authority validation, token acquisition success/failure. Useful for diagnosing outbound auth issues."
  resource_types = ["microsoft.insights/components"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "jwt_auth_events" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    AppTraces
    | where TimeGenerated > ago(1h)
    | where Properties.CategoryName == "AspNetExtensions.JwtBearer"
    | project TimeGenerated, Message, SeverityLevel
    | order by TimeGenerated desc
  KQL
  display_name   = "JWT auth events (last 1h)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["applications"]
  description    = "JWT validation, forbidden, and authentication failure events. Shows issuer, appId, and error details for inbound bot tokens."
  resource_types = ["microsoft.insights/components"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "all_traces_by_category" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    AppTraces
    | where TimeGenerated > ago(1h)
    | extend Category = tostring(Properties.CategoryName)
    | summarize Count = count() by Category
    | order by Count desc
  KQL
  display_name   = "Trace volume by logger category (last 1h)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["applications"]
  description    = "Overview of all logger categories and their volume. Useful for understanding which components are active and noisy."
  resource_types = ["microsoft.insights/components"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "errors_and_warnings" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    AppTraces
    | where TimeGenerated > ago(24h)
    | where SeverityLevel >= 2
    | extend Category = tostring(Properties.CategoryName)
    | project TimeGenerated, SeverityLevel, Category, Message = substring(Message, 0, 300)
    | order by TimeGenerated desc
  KQL
  display_name   = "Errors and warnings (last 24h)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["applications"]
  description    = "All Warning (2) and Error (3) severity traces across all categories. First place to look when something breaks."
  resource_types = ["microsoft.insights/components"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "request_e2e_timeline" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    AppTraces
    | where TimeGenerated > ago(1h)
    | where Properties.CategoryName in (
        "${var.app_namespace}.Functions.BotMessagesFunction",
        "${var.app_namespace}.Services.TeamsBotHandler",
        "Microsoft.Agents.Authentication.Msal.MsalAuth",
        "AspNetExtensions.JwtBearer",
        "Microsoft.Agents.Hosting.AspNetCore.BackgroundQueue.HostedTaskService",
        "Microsoft.Agents.Hosting.AspNetCore.BackgroundQueue.HostedActivityService"
      )
    | extend Category = tostring(Properties.CategoryName)
    | project TimeGenerated, Category, Message = substring(Message, 0, 150), SeverityLevel, OperationId
    | order by TimeGenerated asc
  KQL
  display_name   = "End-to-end request timeline (last 1h)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["applications"]
  description    = "Full timeline of a bot message: inbound HTTP → handler processing → MSAL token → outbound reply. Grouped by operation ID for correlation."
  resource_types = ["microsoft.insights/components"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "outbound_http_calls" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    AppTraces
    | where TimeGenerated > ago(1h)
    | where Properties.CategoryName has "System.Net.Http.HttpClient"
    | where Message startswith "Sending HTTP request" or Message startswith "Received HTTP response"
    | project TimeGenerated, Message = substring(Message, 0, 200)
    | order by TimeGenerated desc
  KQL
  display_name   = "Outbound HTTP calls (last 1h)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["applications"]
  description    = "HttpClient logs for outbound calls — MSAL token endpoint and Bot Connector reply delivery. Shows URL, status, and duration."
  resource_types = ["microsoft.insights/components"]
  tags           = local.query_labels
}

resource "azurerm_log_analytics_query_pack_query" "function_executions" {
  count = var.enable_observability ? 1 : 0

  body           = <<-KQL
    AppTraces
    | where TimeGenerated > ago(1h)
    | where Message startswith "Executed '" or Message startswith "Executing '"
    | project TimeGenerated, Message
    | order by TimeGenerated desc
  KQL
  display_name   = "Function executions (last 1h)"
  query_pack_id  = azurerm_log_analytics_query_pack.bot[0].id
  categories     = ["applications"]
  description    = "All function invocations — BotMessages, QueueProcessor, Health, Notify, etc. Shows success/failure and duration."
  resource_types = ["microsoft.insights/components"]
  tags           = local.query_labels
}
