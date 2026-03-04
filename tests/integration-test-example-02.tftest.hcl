# Integration test for 02-full example
# Apply the example directory as a module and verify outputs.
#
# Note: alert_target_alias is overridden to empty string because Azure Monitor Action Group
# with AAD webhook auth requires the deploying identity to be an owner of the
# target Entra ID app registration (error: AadWebhookResourceNotOwnedByCaller).
# The alerts code is validated via unit tests instead.

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

# Apply example directory as a module
run "apply" {
  command = apply

  module {
    source = "./examples/02-full"
  }

  variables {
    name               = "itbot02"
    bot_app_id         = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    api_app_id         = "11111111-2222-3333-4444-555555555555"
    api_app_object_id  = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
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
}
