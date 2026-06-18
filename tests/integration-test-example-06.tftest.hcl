# Integration test for 06-byo-log-analytics-workspace example.
# Apply the example with a caller-owned LAW passed via `log_analytics_workspace_id`,
# verify the module's `log_analytics_workspace_id` output equals the one we passed
# in (proves the module didn't create its own LAW), and that App Insights is still
# created so the function app has a connection string.

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

run "setup" {
  command = apply

  module {
    source = "./tests/setup"
  }
}

run "apply" {
  command = apply

  module {
    source = "./examples/06-byo-log-analytics-workspace"
  }

  variables {
    name              = "itbot06b"
    bot_app_id        = run.setup.bot_app_id
    api_app_id        = run.setup.api_app_id
    api_app_object_id = run.setup.api_app_object_id
  }

  # Core resources up.
  assert {
    condition     = startswith(output.resource_group_name, "rg-itbot06b")
    error_message = "Resource group name should start with 'rg-itbot06b'."
  }

  assert {
    condition     = output.function_app_name == "func-itbot06b"
    error_message = "Function app name should be 'func-itbot06b'."
  }

  assert {
    condition     = output.bot_service_name == "bot-itbot06b"
    error_message = "Bot service name should be 'bot-itbot06b'."
  }

  # The module's LAW output should equal the externally-created shared LAW —
  # proves BYO took effect (module didn't create its own).
  assert {
    condition     = output.log_analytics_workspace_id == output.shared_log_analytics_workspace_id
    error_message = "Module's log_analytics_workspace_id output should equal the BYO workspace id passed in. Got module=${output.log_analytics_workspace_id}, expected=${output.shared_log_analytics_workspace_id}."
  }

  # The module's LAW output should NOT contain the module-naming pattern
  # (`log-itbot06b`) — proves the module didn't create its own workspace.
  assert {
    condition     = !can(regex("/log-itbot06b$", output.log_analytics_workspace_id))
    error_message = "Module should not have created its own LAW with the standard naming when BYO LAW is provided."
  }

  # App Insights should still exist with a connection string (the toggle was
  # not flipped — only the LAW source changed).
  assert {
    condition     = output.application_insights_connection_string != null
    error_message = "Expected App Insights connection string to be set when enable_observability is true and BYO LAW is provided."
  }
}
