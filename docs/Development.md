# Development of module

Below you can find basic guidelines and rules that must be followed during module development.

## Validate your code

```shell
  # Init project, run fmt and validate
  terraform init -reconfigure
  terraform fmt -recursive
  terraform validate

  # Lint with TFLint, calling script from https://github.com/dsb-norge/terraform-tflint-wrappers
  alias lint='curl -s https://raw.githubusercontent.com/dsb-norge/terraform-tflint-wrappers/main/tflint_linux.sh | bash -s --'
  lint

  # Validate all example directories
  for example_dir in examples/*/; do
    dir_name=${example_dir%*/}
    if ! terraform -chdir=${dir_name} init; then echo "terraform init failed in ${dir_name}"; break; fi
    if ! terraform -chdir=${dir_name} validate; then echo "terraform validate failed in ${dir_name}"; break; fi
    if ! terraform -chdir=${dir_name} fmt -check; then echo "terraform fmt check failed in ${dir_name}"; break; fi
    if ! .tflint/tflint -chdir=${dir_name} --config .tflint.hcl; then echo "tflint failed in ${dir_name}"; break; fi
  done

  # Manually test all examples
  az account set --subscription 'GUID HERE'
  for example_dir in examples/*/; do
    dir_name=${example_dir%*/}
    if ! terraform -chdir=${dir_name} init; then echo "terraform init failed in ${dir_name}"; break; fi
    if ! ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv) terraform -chdir=${dir_name} apply; then echo "terraform apply failed in ${dir_name}"; break; fi
    if ! ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv) terraform -chdir=${dir_name} destroy; then echo "terraform destroy failed in ${dir_name}"; break; fi
  done

  # Run tests using built-in terraform testing framework
  az account set --subscription 'GUID HERE'
  ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv) terraform test

```

## Test isolation and parallel CI runs

Integration tests must be safe to run concurrently. Two CI runs overlap more
often than you would expect — merging to main opens a release PR whose CI races
the next pull request's — and a collision shows up as a confusing failure in
tests you did not touch:

```
Error: creating Storage Account ...: unexpected status 409 (409 Conflict) with error:
StorageAccountAlreadyExists: The storage account named stitbot02b already exists
under the subscription.
```

Most of what the module creates is scoped to a resource group, and resource
groups are already unique because the examples name them with the naming
module's `name_unique`. But three names derived from `var.name` live in
**global** namespaces and will collide across concurrent runs:

| Resource | Name | Scope |
| -------- | ---- | ----- |
| Storage account | `st<name>` | global |
| Function app | `func-<name>` | global (owns an `azurewebsites.net` hostname) |
| Bot service | `bot-<name>` | global |

So the setup modules generate the name rather than the test hardcoding it.
`tests/setup` takes a `name_prefix` identifying the test, appends a six
character random suffix, and returns the result as `name`:

```hcl
run "setup" {
  command = apply

  module {
    source = "./tests/setup"
  }

  variables {
    name_prefix = "itbot01"
  }
}

run "apply" {
  command = apply

  module {
    source = "./examples/01-basic"
  }

  variables {
    name = run.setup.name
  }
}
```

Assertions on derived names interpolate the same value —
`output.function_app_name == "func-${run.setup.name}"` — so they keep their
meaning without pinning a literal.

Two things to keep in mind when adding a test:

- **Keep the prefix short.** The module's `name` validation allows at most 22
  characters once hyphens are stripped, and the suffix consumes six of them.
- **The suffix is generated once per test file**, in the `setup` run, and is
  stable for every later run block in that file. That is what lets the
  idempotency runs below re-target the resources an earlier run created. A test
  that generates a fresh name per run block would deploy a new environment each
  time instead.

`tests/setup-byon-bad-delegation` generates its own suffix because its test
does not also load `tests/setup`. `tests/setup-byon-identity` does not — the
test using it passes `run.setup.name` straight through, so the identity and the
bot share one run's name.

## Idempotency testing

`tests/integration-test-example-01.tftest.hcl` ends with two extra `run` blocks —
`second_apply` and `plan_after_apply_converges` — that check the module
converges: applying it twice in a row must not rebuild anything, and a plan
taken afterwards must not still want to change things.

This matters because the function app is an `azapi_resource` submitting a large
ARM body. If Azure normalises or rejects any part of what we send, every
consumer sees a permanent diff and every apply rewrites the site — including
its `appSettings`. That failure mode is invisible to unit tests, which never
talk to Azure.

### How the repeat operation works

Run blocks that share a `module` source share one state file. Terraform's
documentation puts it this way: *"An alternate module state file is shared by
all `run` blocks that execute the given module."* So a later run block naming
the same source operates on the resources an earlier one created — it is a
genuine second apply, not a fresh deployment. No `import` block or state
juggling is needed. (If you ever need to override that pairing, the `state_key`
attribute on a run block controls it explicitly.)

### Why the assertions look indirect — the workaround

**Terraform cannot assert that a plan is empty.** There is no `expect_no_changes`
and no way to inspect the diff from a test. The `plan` and `state` symbols were
reserved for exactly this when the test framework launched, but the feature has
never been implemented — the tracking issue,
[hashicorp/terraform#34500](https://github.com/hashicorp/terraform/issues/34500),
has been open since January 2024. Writing the syntax people suggest online fails:

```
Error: Reserved symbol name
  The symbol name "plan" is reserved for use in a future Terraform version.
```

So these tests use the workaround a Terraform maintainer recommends on that
issue: **compare outputs across run blocks**. A later run can reference an
earlier one's outputs as `run.<name>.<output>`, and the comparison does double
duty:

- After `command = apply`, an inequality means the resource was actually
  rebuilt between applies.
- After `command = plan`, the check is sharper than it looks. If the plan
  intends to change a resource, the outputs it feeds become *unknown*, and
  Terraform fails the assertion with `Unknown condition value` rather than the
  block's own `error_message`. A failure that names a missing value rather than
  quoting our message is still a real failure — read it as "this resource is
  not converging".

Only **remote-derived** outputs are compared (`function_app_hostname`,
`vnet_id`, `log_analytics_workspace_id`, `private_endpoint_ids`). Outputs
computed from input variables — names, and anything derived from `var.*` — are
identical on a re-apply by construction and would prove nothing.

### What this does and does not catch

Catches: a resource that is rebuilt on the second apply; a resource that creates
successfully but fails on the update path; a property Azure returns differently
from what we submitted, for any attribute feeding one of the compared outputs.

Does not catch: an in-place update to an attribute that feeds none of the
compared outputs. Widening coverage means comparing more remote-derived
outputs, not a different technique.

Note also that an *empty* plan would be the wrong bar for this module even if
Terraform could assert one. `azapi_resource_action.register_microsoft_app`
deliberately re-runs on every apply (see the comment in `main.compute.tf`), so
convergence here means "nothing is rebuilt or rewritten", not "the plan is
byte-empty".

One further caveat specific to app settings: ARM's `GET` on
`Microsoft.Web/sites` returns `siteConfig.appSettings` as `null` — the values
are only retrievable via `POST .../config/appsettings/list`. The provider
therefore has no read path for app settings and cannot detect drift in them at
all, so these tests cannot observe app-setting convergence. They cover the rest
of the site body.

## Release and versioning

This module uses [semantic versioning](https://semver.org).
Always use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) in your pull-requests.
Module is using [release-please action](https://github.com/googleapis/release-please-action) and it create release PR based on commit message after PR is merged to main.
Use [respective conventional commits](https://github.com/googleapis/release-please?tab=readme-ov-file#how-should-i-write-my-commits) to achieve correct [SemVer](https://semver.org) release version.

Refer to [release-please documentation](https://github.com/googleapis/release-please) for better understanding and when additional questions occur.

## Documentation

Repo CI action has step to generate terraform documentation automatically using [terraform-docs action](https://github.com/terraform-docs/gh-actions) and configuration files in repo.
It is, however, possible to run ```terraform-docs``` locally to check documentation during development or when other need occur.

### Generate and inject terraform-docs in README.md

```shell
# go1.17+
go install github.com/terraform-docs/terraform-docs@v0.19.0
export PATH=$PATH:$(go env GOPATH)/bin

# root
terraform-docs .

# docs for examples
for ex_dir in $(find "./examples" -maxdepth 1 -mindepth 1 -type d | sort); do
  terraform-docs "${ex_dir}" --config ./examples/.terraform-docs.yml
done
```
