# Integration test: BYON subnet without required delegation
# Verifies that the module rejects a function app subnet that is NOT
# delegated to Microsoft.App/environments.

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

# Create infrastructure with a deliberately misconfigured subnet
run "setup" {
  command = apply

  module {
    source = "./tests/setup-byon-bad-delegation"
  }

  variables {
    name = "itbad01"
  }
}

# The module should reject the undelegated subnet during plan
run "rejects_missing_delegation" {
  command = plan

  variables {
    name                = "itbad01"
    resource_group_name = run.setup.resource_group_name
    bot_app_id          = run.setup.bot_app_id
    api_app_id          = run.setup.api_app_id
    api_app_object_id   = run.setup.api_app_object_id
    app_requirements    = {}

    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = run.setup.subnet_function_app_id
      existing_subnet_private_endpoints_id = run.setup.subnet_private_endpoints_id
      manage_private_dns_zone_groups       = false
    }
  }

  expect_failures = [data.azapi_resource.byon_subnet_function_app[0]]
}
