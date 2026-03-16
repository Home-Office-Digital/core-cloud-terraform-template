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
   Update the existing **main.tf**, **outputs.tf**, **providers.tf** and **variables.tf** for your project.
   Replace **env-a**, **env-b** and **env-c** with your existing environments and add the required values
   If using child modules within this repo, replace **modules/module1** and **modules/module2** with the required code
   Create your TF tests for your given service, remember to replace **module1** and **module2** in **.github/workflows/terraform-tests.yaml**


3. **Update `tf-validate yaml file`** 
   Replace <GITHUB_ENVIRONMENT_NAME> with value for Environment
   Replace <TF_STATE_S3_BUCKET> with Terraform State S3 bucket name
   Replace <TF_STATE_KEY> with required subfolder in TF State Bucket i.e. github/terraform.state
   Replace <IAM_ROLE_TO_CREATE_RESOURCES> with required IAM role name which performs the TF Apply
   Repace <ENV> with ENV Short name used in Repo Secrets i.e. LIVE_ACCOUNT_ID

4. **Update `deploy-resources yaml file`** 
   Replace **env-a**, **env-b** and **env-c** for **github-environment** with appropriate value for Environment
   Replace <TF_STATE_DYNAMODB_TABLE> with Terraform State DynamoDB table
   Replace <IAM_ROLE_TO_CREATE_RESOURCES> with required IAM role name which performs the TF Apply
   Replace **service-name** with appropriate service-name that is being deployed
   Enable deployments on push for feature branches, uncomment out lines 4,5 and 6

5. **Review `CODEOWNERS`**  
   Update the `CODEOWNERS` file to reflect the correct team members responsible for this repository.

6. **Set Repository Settings**  
   Configure these settings under **Settings > Branches**:
   - Enable branch protection rules (e.g., require PR reviews)
   - Configure required reviewers - this is also defined at the org level as a ruleset.
   - Set merge policies (e.g., allow squash merges only)

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