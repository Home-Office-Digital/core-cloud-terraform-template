# Core Cloud Terraform Template

Starting point for a repository that deploys Terraform with the Core Cloud workflows in [core-cloud-workflow-terraform-actions](https://github.com/Home-Office-Digital/core-cloud-workflow-terraform-actions) `1.3.0`.

## Structure

```text
source/terraform/
  deployments.json          # account, roles and state bucket per deployment
  components/
    <component-name>/                   # component: a root module
      *.tf
      tests/                            # *.tftest.hcl, run with mocked providers
      environments/
        dev/<deployment-name>.tfvars    # deployment: one tfvars file per target
        test/<deployment-name>.tfvars
        prod/<deployment-name>.tfvars
  modules/
    <module-name>/                      # optional child module, shared by components
      *.tf
      tests/                            # *.tftest.hcl, tested on PRs
```

- A component is a root module under `components/`.
- A child module lives under `modules/<module-name>/` and is called from a component by relative path, such as `../../modules/<module-name>`.
- A deployment is a `.tfvars` file in `environments/<environment-name>/`. Its filename is its name, and it gets its own state. Add files to deploy more targets in the same environment.
- `deployments.json` has one entry per deployment, keyed `<component-name>/<environment-name>/<deployment-name>`. A `.tfvars` file without an entry, or an entry without a file, fails the run.
- Each `<environment-name>` folder must match the name of a GitHub Environment, such as `dev`, `test` or `prod`. Every apply waits for approval on that environment.

## Setup

1. Create the repository from this template.
2. Rename `<component-name>` and the `<deployment-name>.tfvars` files, using lowercase letters, digits and hyphens. Update the keys in `deployments.json` and the `directory` in `.github/dependabot.yml` to match.
3. Set `project_name` and the tags in each `.tfvars` file.
4. Replace the remaining placeholders in `deployments.json` with real account IDs, role names and state bucket names.
5. In each account, create a plan role and an apply role that this repository can assume through OIDC.
6. Create the `dev`, `test` and `prod` GitHub Environments, each with required reviewers.
7. Update `CODEOWNERS` and the `<team-name>` placeholders in `.github/dependabot.yml`.

The workflows fail until steps 4 to 6 are done.

## Triggers

| Trigger | Result |
|---|---|
| Pull request | Lint, test and plan against `dev`. Nothing is applied. |
| Merge to `main` | Deploys `dev` |
| Pre-release published | Deploys `test` |
| Release published | Deploys `prod` |
| Manual dispatch | Deploys the environment, version and components you choose |

Run a manual dispatch from **Actions > Terraform Deploy > Run workflow**. Use it to roll back, deploy one component, or plan without applying (`plan-only`). Outside `dev`, the version must be `main` or a release tag.

## Testing a PR in dev

Dispatch with `ephemeral` ticked and your PR branch as the version. It deploys into a throwaway `pr-<n>-<deployment-name>` workspace in `dev`, separate from the real `dev` state. Use `local.name_prefix` in resource names so they don't clash with `dev`.

Workspaces are removed weekly once the PR closes. To remove them sooner, run **Terraform Ephemeral Cleanup** with `scope` set to `pr-<n>`.
