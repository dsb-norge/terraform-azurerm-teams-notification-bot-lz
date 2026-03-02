# Integration test for 01-basic scenario
# Step 1: Create RG + assign storage data plane RBAC to deploying identity
# Step 2: Deploy the module into that RG and verify outputs

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

provider "azapi" {}

run "setup" {
  command = apply

  module {
    source = "./tests/setup"
  }

  variables {
    name = "itbot01"
  }
}

run "deploy_basic" {
  command = apply

  variables {
    name                = "itbot01"
    resource_group_name = run.setup.resource_group_name
    bot_app_id          = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    api_app_id          = "11111111-2222-3333-4444-555555555555"
    api_app_object_id   = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  }

  assert {
    condition     = startswith(output.resource_group_name, "rg-itbot01")
    error_message = "Resource group name should start with 'rg-itbot01'."
  }

  assert {
    condition     = output.function_app_name == "func-itbot01"
    error_message = "Function app name should be 'func-itbot01'."
  }

  assert {
    condition     = output.bot_service_name == "bot-itbot01"
    error_message = "Bot service name should be 'bot-itbot01'."
  }

  assert {
    condition     = output.storage_account_name == "stitbot01"
    error_message = "Storage account name should be 'stitbot01'."
  }

  assert {
    condition     = output.function_app_hostname != ""
    error_message = "Function app hostname must not be empty."
  }

  assert {
    condition     = output.log_analytics_workspace_id != ""
    error_message = "Log Analytics workspace ID must not be empty."
  }
}
