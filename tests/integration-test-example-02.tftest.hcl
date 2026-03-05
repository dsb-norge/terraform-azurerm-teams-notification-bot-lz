# Integration test for 02-full example
# Apply the example directory as a module and verify outputs.
# Mode 1 (default) with alerts, CI/CD deploy UAMI, and custom tags.
#
# Note: alert_target_alias is overridden to empty string because Azure Monitor Action Group
# with AAD webhook auth requires the deploying identity to be an owner of the
# target Entra ID app registration (error: AadWebhookResourceNotOwnedByCaller).
# The alerts code is validated via unit tests instead.

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

# Generate random UUIDs for app registration placeholders to avoid
# MsaAppId collisions when integration tests run in parallel.
run "setup" {
  command = apply

  module {
    source = "./tests/setup"
  }
}

# Apply example directory as a module
run "apply" {
  command = apply

  module {
    source = "./examples/02-full"
  }

  variables {
    name               = "itbot02"
    bot_app_id         = run.setup.bot_app_id
    api_app_id         = run.setup.api_app_id
    api_app_object_id  = run.setup.api_app_object_id
    alert_target_alias = "" # see note at top of file
  }

  assert {
    condition     = startswith(output.resource_group_name, "rg-itbot02")
    error_message = "Resource group name should start with 'rg-itbot02'."
  }

  assert {
    condition     = output.function_app_name == "func-itbot02"
    error_message = "Function app name should be 'func-itbot02'."
  }

  assert {
    condition     = output.bot_service_name == "bot-itbot02"
    error_message = "Bot service name should be 'bot-itbot02'."
  }

  assert {
    condition     = output.deploy_uami_client_id != null
    error_message = "Deploy UAMI client ID should be set when github repos are configured."
  }

  assert {
    condition     = output.log_analytics_workspace_id != ""
    error_message = "Log Analytics workspace ID must not be empty."
  }

  # Mode 1 network outputs: module creates its own VNet and subnets
  assert {
    condition     = output.vnet_id != null
    error_message = "Mode 1 should create a VNet (vnet_id should be non-null)."
  }

  assert {
    condition     = length(output.private_endpoint_ids) == 3
    error_message = "Mode 1 should create 3 private endpoints."
  }
}
