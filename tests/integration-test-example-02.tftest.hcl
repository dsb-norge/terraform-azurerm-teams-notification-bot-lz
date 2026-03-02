# Integration test for 02-full scenario
# Step 1: Create RG + assign storage data plane RBAC to deploying identity
# Step 2: Deploy the module with all features enabled and verify outputs
#
# Note: alert_target_alias is NOT tested here because Azure Monitor Action Group
# with AAD webhook auth requires the deploying identity to be an owner of the
# target Entra ID app registration (error: AadWebhookResourceNotOwnedByCaller).
# The alerts code is validated via unit tests instead.

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
    name = "itbot02"
  }
}

run "deploy_full" {
  command = apply

  variables {
    name                = "itbot02"
    resource_group_name = run.setup.resource_group_name
    bot_app_id          = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    api_app_id          = "11111111-2222-3333-4444-555555555555"
    api_app_object_id   = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

    # alert_target_alias omitted — see note at top of file
    app_namespace = "NotificationBot"

    management_ip_rules = [
      {
        name        = "ci-runner"
        description = "GitHub Actions runner IP"
        cidr        = "203.0.113.0/24"
      },
    ]

    github_org = "example-org"
    deploy_github_actions_from = {
      "example-repo" = {
        environments = ["production"]
        branches     = ["main"]
      }
    }

    tags = {
      "ApplicationName" = "Notifications"
      "owner"           = "platform-team"
    }
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
