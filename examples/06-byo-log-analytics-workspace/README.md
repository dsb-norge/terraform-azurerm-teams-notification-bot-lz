# BYO Log Analytics Workspace Example

Deploys the bot landing zone configured to send all telemetry to an externally-owned Log Analytics workspace, instead of one the module creates itself.

This is the typical setup when a central platform team owns a shared workspace for cross-workload correlation (security signals, cost rollups, etc.) and individual workloads route their diag settings to it.

What this changes vs. the default (`enable_observability = true`, `log_analytics_workspace_id = null`):

| Resource | Default | BYO LAW |
|---|---|---|
| Log Analytics workspace | Created by the module under `var.resource_group_name` | Module skips creation; uses the workspace passed via `var.log_analytics_workspace_id` |
| Application Insights | Created, `workspace_id` → module's LAW | Created, `workspace_id` → BYO LAW |
| Diagnostic settings | Routed to module's LAW | Routed to BYO LAW |
| Saved-query pack | Created under `var.resource_group_name` | Same — query packs are per-RG, decoupled from the LAW location |
| Action group / metric alerts | Same | Same |

If you want the module to skip the observability stack entirely (no LAW, no AI, no diag settings), see [`05-observability-disabled`](../05-observability-disabled/) instead.

## Usage

```bash
terraform init
terraform plan -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
terraform apply -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
```

In production this example would reference an existing workspace via a `data` source rather than creating one alongside the module — the integration test creates one here so the example is self-contained.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
