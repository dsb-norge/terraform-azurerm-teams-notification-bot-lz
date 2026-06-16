# Observability Disabled Example

Deploys the bot landing zone with `enable_observability = false`. The module skips the entire observability stack:

- No Log Analytics workspace
- No Application Insights
- No saved-query pack
- No diagnostic settings on any resource (function app, storage, bot service, service plan)
- No action group / metric alerts (regardless of `alert_target_alias`)

The function app still runs — it just has no telemetry. `APPLICATIONINSIGHTS_CONNECTION_STRING` is not set, so the App Insights SDK initializes in no-op mode.

Use this when an external observability stack collects telemetry through another mechanism (Azure Container Apps platform logs, an external SIEM forwarder, etc.), or for cost-sensitive non-production scenarios where you genuinely don't want telemetry.

If you want to use the module's observability resources but route logs to a workspace you already own, see [`06-byo-log-analytics-workspace`](../06-byo-log-analytics-workspace/) instead.

## Usage

```bash
terraform init
terraform plan -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
terraform apply -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
