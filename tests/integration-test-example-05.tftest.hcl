# Integration test for 05-observability-disabled example.
# Apply the example with `enable_observability = false` and verify the module
# emits null for all observability-related outputs (no LAW, no AI, etc.) while
# still producing a healthy function app + bot service.

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

# Random UUIDs for the bot/api app registration placeholders so this test
# can run in parallel with other integration tests without MsaAppId collisions.
run "setup" {
  command = apply

  module {
    source = "./tests/setup"
  }

  variables {
    name_prefix = "itbot05"
  }
}

run "apply" {
  command = apply

  module {
    source = "./examples/05-observability-disabled"
  }

  variables {
    name              = run.setup.name
    bot_app_id        = run.setup.bot_app_id
    api_app_id        = run.setup.api_app_id
    api_app_object_id = run.setup.api_app_object_id
  }

  # Core resources still come up.
  assert {
    condition     = startswith(output.resource_group_name, "rg-${run.setup.name}")
    error_message = "Resource group name should start with 'rg-<name>'."
  }

  assert {
    condition     = output.function_app_name == "func-${run.setup.name}"
    error_message = "Function app name should be 'func-<name>'."
  }

  assert {
    condition     = output.bot_service_name == "bot-${run.setup.name}"
    error_message = "Bot service name should be 'bot-<name>'."
  }

  assert {
    condition     = output.storage_account_name == "st${run.setup.name}"
    error_message = "Storage account name should be 'st<name>'."
  }

  assert {
    condition     = output.function_app_hostname != ""
    error_message = "Function app hostname must not be empty."
  }

  # All observability outputs must be null — proves the toggle suppressed
  # both the workspace and App Insights.
  assert {
    condition     = output.log_analytics_workspace_id == null
    error_message = "Expected log_analytics_workspace_id to be null when enable_observability = false."
  }

  assert {
    condition     = output.application_insights_connection_string == null
    error_message = "Expected application_insights_connection_string to be null when enable_observability = false."
  }

  assert {
    condition     = output.application_insights_instrumentation_key == null
    error_message = "Expected application_insights_instrumentation_key to be null when enable_observability = false."
  }
}
