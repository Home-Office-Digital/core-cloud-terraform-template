# Core Cloud Terraform Template

Starting point for a repository that deploys Terraform with the Core Cloud workflows in [core-cloud-workflow-terraform-actions](https://github.com/Home-Office-Digital/core-cloud-workflow-terraform-actions). The version is pinned in each workflow under `.github/workflows/`.

The repository has two Terraform folders, each with its own pipeline:

| Folder | Deploys | Runs as |
|---|---|---|
| `source/terraform-bootstrap` | The plan and apply roles `source/terraform` deploys with | The bootstrap roles in each account |
| `source/terraform` | Your product's supporting infrastructure | The roles that bootstrap creates |

Deploy bootstrap first: the product pipeline can't run until its roles exist. Every role bootstrap creates must carry the account's permissions boundary.

## Structure

```text
source/
  terraform-bootstrap/
    deployments.json                                # per deployment: account, bootstrap roles, state bucket
    components/pipeline-roles/                      # the roles source/terraform deploys with
      plan-policy.tf                                # read-only
      apply-policy.tf
      environments/<env>/<deployment-name>.tfvars   # a plan and apply role pair in one account
  terraform/
    deployments.json                                # per deployment: account, pipeline-roles' roles, state bucket
    components/<component-name>/
      *.tf
      tests/
      environments/<env>/<deployment-name>.tfvars   # a deployment, with its own state
    modules/<module-name>/                          # optional, shared by components
```

- A component is a root module. Further components are supported. Merges and releases deploy them in parallel, so dispatch one at a time where order matters.
- A deployment is one instance of a component in an environment: a `.tfvars` file with its own state. Name it after what makes that instance distinct.
- `deployments.json` maps each deployment to its account, roles and state bucket. Product deployments in the same account can share one role pair. Every `.tfvars` file needs an entry, and every entry a file.

  ```json
  "component-name/development/deployment-name": {
    "account_id": "123456789012",
    "plan_role_name": "myrepo-plan",
    "apply_role_name": "myrepo-apply",
    "state_bucket_name": "myproduct-dev-tfstate"
  }
  ```

- Each `<environment-name>` folder must match the name of a GitHub Environment, such as `development`, `pre-release` or `release`. Every apply waits for approval on that environment.
- Both folders can share a state bucket. Their state keys don't overlap.

## Setup

1. Rename `component-name` and the `deployment-name.tfvars` files, using lowercase letters, digits and hyphens, then update the `deployments.json` keys and `.github/dependabot.yml` to match. Do this before the first deploy: a renamed `.tfvars` file points at fresh state.
2. Set the placeholder values:

   | File | Set |
   |---|---|
   | Bootstrap `deployments.json` | Account IDs, bootstrap role names, state bucket names |
   | Bootstrap `.tfvars` | `github_repository`, `permissions_boundary_name`, `state_bucket_name`, `plan_role_name`, `apply_role_name`, `tags` |
   | Product `deployments.json` | Account IDs, state bucket names, and the role names from the bootstrap `.tfvars` |
   | Product `.tfvars` | `project_name`, `tags` |
   | `.github/CODEOWNERS`, `.github/dependabot.yml` | Your team |

3. Create the `development`, `pre-release` and `release` GitHub Environments with required reviewers, and limit `pre-release` and `release` to `main` and tags.
4. Merge to `main` to deploy the bootstrap roles to `development`, then run **Terraform Bootstrap Deploy** for `pre-release` and `release`.
5. Build your supporting infrastructure in `source/terraform`. For each resource, add a statement to `plan-policy.tf` and `apply-policy.tf`, below the state statements. The tests fail if `plan-policy.tf` allows anything but `Get*`, `List*` and `Describe*`. Merge permission changes before the product change that needs them, so bootstrap deploys first. For example:

   ```hcl
   # plan-policy.tf
   statement {
     sid       = "ReadParameters"
     actions   = ["ssm:GetParameter*", "ssm:ListTagsForResource"]
     resources = ["arn:aws:ssm:${var.aws_region}:${local.account_id}:parameter/myproduct/*"]
   }

   # apply-policy.tf
   statement {
     sid       = "ManageParameters"
     actions   = ["ssm:*"]
     resources = ["arn:aws:ssm:${var.aws_region}:${local.account_id}:parameter/myproduct/*"]
   }
   ```

## Triggers

Both pipelines run on pull requests, on merges to `main` and by manual dispatch. Only the product pipeline deploys on releases, so dispatch bootstrap to `pre-release` and `release` before releasing a product change that needs new permissions.

| Trigger | Bootstrap | Product |
|---|---|---|
| Pull request touching the folder | Lint, test and plan against `development` | Lint, test and plan against `development` |
| Merge to `main` | Deploys `development` | Deploys `development` |
| Pre-release published | Nothing | Deploys `pre-release` |
| Release published | Nothing | Deploys `release` |
| Manual dispatch | Deploys the environment, version and deployments you choose | Deploys the environment, version, components and deployments you choose |

Outside `development`, a dispatch must deploy `main` or a release tag. Set `plan-only` to plan any ref without applying.

## Testing before merge

A merge to `main` deploys `development`. To test a change before merging, dispatch **Terraform Deploy** with your branch as the version, either:

- with `ephemeral` ticked, to deploy into a throwaway `pr-<n>-<deployment-name>` workspace in `development`, separate from its state. It needs an open PR. Use `local.name_prefix` in resource names so they don't clash.
- to `development` without `ephemeral`, to deploy over what's there until the next merge.

Ephemeral workspaces are removed weekly once the PR closes. To remove them sooner, run **Terraform Ephemeral Cleanup** with `scope` set to `pr-<n>`. Bootstrap has no ephemeral deploys.

## Access

- The plan role trusts any ref of this repository. The apply role trusts only its GitHub Environment, plus `main` in `development` for ephemeral cleanup.
- Neither role can touch the bootstrap state.
- Trust assumes GitHub's default OIDC subject format.
