# Core Cloud Terraform Module Repository Template

Welcome! This repository serves as a **template** for creating terraform module repositories for use across core cloud. Follow the steps below to initialize and customize your own repository using this template.

---

## 🚀 Getting Started

To create a new repository using this template:

1. Click the **"Use this template"** button at the top of this page.
2. Name your repository using the format agreed within your team
3. Set the visibility (preferably **Private**).
4. Click **"Create repository from template"**.

---

## 🔧 Post-Creation Customization

Once your repository is created, perform the following setup steps:

1. **Update `README.md`**  
   Replace this file with details specific to your project.


2. **Add TF specific files**  
   - Update the existing **main.tf**, **outputs.tf**, **providers.tf** and **variables.tf** for your project.  
   - Replace **env-a**, **env-b** and **env-c** with your existing environments and add the required values.
   - If using child modules within this repo, replace **modules/module1** and **modules/module2** with the required code.  
   - Create your TF tests for your given service, remember to replace **module1** and **module2** in **.github/workflows/terraform-tests.yaml**


3. **Update `tf-validate yaml file`** 
   - Replace <GITHUB_ENVIRONMENT_NAME> with value for Environment. 
   - Replace <TF_STATE_S3_BUCKET> with Terraform State S3 bucket name. 
   - Replace <TF_STATE_KEY> with required subfolder in TF State Bucket i.e. github/terraform.state.
   - Replace <IAM_ROLE_TO_CREATE_RESOURCES> with required IAM role name which performs the TF Apply
   - Replace <ENV> with ENV Short name used in Repo Secrets i.e. LIVE_ACCOUNT_ID.

4. **Update `deploy-resources yaml file`** 
   - Replace **env-a**, **env-b** and **env-c** for **github-environment** with appropriate value for Environment. 
   - Replace <TF_STATE_DYNAMODB_TABLE> with Terraform State DynamoDB table. 
   - Replace <IAM_ROLE_TO_CREATE_RESOURCES> with required IAM role name which performs the TF Apply. 
   - Replace **service-name** with appropriate service-name that is being deployed. 
   - Enable deployments on push for feature branches, uncomment out lines 4,5 and 6. 

5. **Review `CODEOWNERS`**  
   - Update the `CODEOWNERS` file to reflect the correct team members responsible for this repository.

6. **Set Repository Settings**  
   Configure these settings under **Settings > Branches**:
   - Enable branch protection rules (e.g., require PR reviews)
   - Configure required reviewers - this is also defined at the org level as a ruleset.
   - Set merge policies (e.g., allow squash merges only)

## 🔐 Managing Secrets with AWS Secrets Manager

AWS Secrets Manager support is added by defining the secret resources in Terraform and then supplying the right values in your environment tfvars.

1. Ensure `<IAM_ROLE_TO_CREATE_RESOURCES>` has the relevant permissions to create/update/delete secrets.

2. Choose how each secret should be created

This template supports two creation modes through `terraform/secrets-manager.tf`:

- **Empty shell**: creates the Secrets Manager secret only, leaving the value to be added manually after deployment
- **Dynamically Generated**: creates the secret and writes a generated password into the current version using `random_password`

The input is `managed_secrets`, which defaults to an empty map so nothing is created unless you opt in.

3. Add secret definitions to your environment tfvars

Copy the example in `terraform/secrets-manager.example.tfvars` into the environment file you want to deploy, then tailor it for that environment.

Example:

```hcl
managed_secrets = {
  empty_shell = {
    description = "Create the container only; populate the value manually later."
    mode        = "empty"
  }

  generated_database_admin = {
    mode        = "generated"
    secret_name = "my-service/live/database-admin"
    secret_string_template = {
      username = "dbadmin"
      engine   = "postgres"
    }
  }
}
```

For generated secrets, the template stores a JSON payload built from `secret_string_template` plus a generated `password` key.

4. Retrieve existing secrets for reuse

Use `existing_secret_names` to look up secrets that already exist in the target AWS account. The stack exposes:

- `data.aws_secretsmanager_secret.existing`
- `data.aws_secretsmanager_secret_version.existing`
- `local.existing_secret_strings`
- `local.existing_secret_json`

That lets you inject an existing secret into other resources without hard-coding credentials in Terraform.

Example:

```hcl
existing_secret_names = [
  "hello-world-app"
]

example_rds_secret_name = "hello-world-app"
```

If the secret value is JSON such as:

```json
{
  "username": "app_user",
  "password": "super-secret-value"
}
```

then `local.existing_secret_json["hello-world-app"]` gives you a decoded map that can be passed into resources like `aws_db_instance`.

## 🤝 Contribution Workflow

### Pull Requests
We recommend using our [Pull Request Template](pull_request_template.md) when submitting changes. Please:

1. Reference the Ticket in your PR 
3. Keep PRs focused on a single change
4. Include clear descriptions and screenshots if applicable


## 🔄 Dependency Management with Dependabot

This repository includes Dependabot configuration to:
- Automatically check for dependency updates
- Create PRs for security updates (critical/high severity)
- Weekly version updates for other dependencies

To use Dependabot effectively:
1. Review Dependabot PRs promptly
2. Test dependency updates in a non-production environment first
3. Check the [Dependabot documentation](https://docs.github.com/en/code-security/dependabot) for more options

Configuration files:
- `.github/dependabot.yml` - Update frequency and package ecosystems and teams
