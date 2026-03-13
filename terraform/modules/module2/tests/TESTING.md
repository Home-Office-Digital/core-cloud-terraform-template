# Terraform Module Testing Guide

## Overview
This repository uses Terraform's native test framework to validate infrastructure modules for the Core Cloud Tooling Resources deployed via Terragrunt.

## Why Native Terraform Tests?

- ✅ **No additional dependencies** - No Go, Python, or Ruby required
- ✅ **Fast execution** - Tests run using `terraform plan` (no actual deployments)
- ✅ **Easy to write** - HCL syntax, familiar to Terraform users
- ✅ **CI/CD integrated** - Automatic validation on every PR
- ✅ **Hard quality gate** - Failed tests block merges

## Test Structure

Each module has organized test suites covering different aspects:

### S3 Module Tests (`modules/s3/tests/`)

| Test File | Purpose | Validates |
|-----------|---------|-----------|
| `s3_basic.tftest.hcl` | Resource creation | Bucket naming, KMS key creation, versioning, KMS alias |
| `s3_security.tftest.hcl` | Security compliance | Encryption (KMS/AES256), public access blocks |
| `s3_tagging.tftest.hcl` | Tag compliance | Required tags, tag values, tag merging |

**Key S3 Test Coverage:**
- Bucket naming pattern: `{project_name}-{bucket_name}-{environment}-s3`
- KMS key creation and encryption configuration
- Versioning enabled/suspended based on variable
- All 4 public access block settings enabled
- Tags: Environment, Project, ManagedBy, source-repo
- Custom tag merging via `var.tags`

### RDS Module Tests (`modules/rds/tests/`)

| Test File | Purpose | Validates |
|-----------|---------|-----------|
| `rds_basic.tftest.hcl` | Resource creation | Instance configuration, storage, subnet groups, multi-AZ |
| `rds_security.tftest.hcl` | Security compliance | Encryption, backups, monitoring, network security, deletion protection |
| `rds_tagging.tftest.hcl` | Tag compliance | Required tags on instances, security groups, subnet groups |
| `rds_engines.tftest.hcl` | Engine support | Port mappings for different database engines |

**Key RDS Test Coverage:**
- Managed password instances (`manage_master_user_password = true`)
- Custom password instances with Secrets Manager
- Security group creation with correct engine ports
- DB subnet group creation
- Multi-AZ for live environments
- Deletion protection for production
- Backup retention ≥7 days
- CloudWatch logs exports
- Storage encryption
- Tags: Name, source-repo, plus custom tags

## Running Tests Locally

### Prerequisites
```bash
# Terraform 1.6.0+ required for native test support
terraform --version

# Should output: Terraform v1.6.0 or higher
```

### S3 Module Tests
```bash
# Navigate to S3 module
cd modules/s3

# Initialize (only needed first time)
terraform init

# Run all S3 tests
terraform test

# Run specific test file
terraform test -filter=tests/s3_security.tftest.hcl

# Verbose output for debugging
terraform test -verbose
```

**Expected output:**
```
Success! 15 passed, 0 failed.
```

### RDS Module Tests
```bash
# Navigate to RDS module
cd modules/rds

# Initialize (only needed first time)
terraform init

# Run all RDS tests
terraform test

# Run specific test file
terraform test -filter=tests/rds_security.tftest.hcl

# Verbose output
terraform test -verbose
```

**Expected output:**
```
Success! 25 passed, 0 failed.
```

## CI/CD Integration

### Automatic Testing

Tests run automatically on:
- **Pull requests** modifying `modules/**` or `terraform/**`
- **Pushes to main** branch
- **Manual trigger** via workflow dispatch

### Intelligent Path Filtering

Only changed modules are tested:
- Change `modules/s3/**` → Only S3 tests run
- Change `modules/rds/**` → Only RDS tests run
- Change both → Both test suites run

This keeps PR feedback fast (typically under 2 minutes).

### Test Results

**On Pull Requests:**
- ✅ **Passed**: Green checkmark, ready to merge
- ❌ **Failed**: Red X, merge blocked by branch protection
- Test results posted as PR comment
- Full logs available in GitHub Actions

**Artifacts Retention:**
- Test logs retained for 30 days
- Download from Actions → Artifacts
- Useful for debugging complex failures

### Hard Quality Gate

The workflow includes a **required status check** (`quality-gate`) that:
- ✅ Blocks PR merge if any tests fail
- ✅ Must pass before merge is allowed
- ✅ Configured in branch protection rules

## Test File Structure

### Example: S3 Basic Test
```hcl
# modules/s3/tests/s3_basic.tftest.hcl

variables {
  bucket_name  = "test-bucket"
  project_name = "core-cloud"
  environment  = "test"
  source-repo  = "github.com/UKHomeOffice/core-cloud-tooling-resources-terragrunt"
  
  tags = {
    Environment  = "test"
    Project      = "core-cloud"
    cost-centre  = "123456"
    account-code = "ACC001"
    portfolio-id = "PORT001"
    project-id   = "PROJ001"
    service-id   = "SVC001"
  }
}

run "validate_bucket_creation" {
  command = plan

  assert {
    condition     = aws_s3_bucket.this.bucket == "core-cloud-test-bucket-test-s3"
    error_message = "Bucket name should follow pattern: {project_name}-{bucket_name}-{environment}-s3"
  }
}
```

### Anatomy of a Test

1. **`variables` block**: Set input variables for the test
2. **`run` block**: Define a test scenario
3. **`command = plan`**: Use `plan` (fast) instead of `apply` (slow/expensive)
4. **`assert` blocks**: Validate expected behavior
5. **`condition`**: Boolean expression to check
6. **`error_message`**: Helpful message when assertion fails

## Writing New Tests

### Best Practices

1. **Test one thing per assertion**
```hcl
   # Good ✅
   assert {
     condition     = aws_s3_bucket.this.bucket != ""
     error_message = "Bucket name must be defined"
   }
   
   assert {
     condition     = aws_s3_bucket.this.versioning.enabled == true
     error_message = "Versioning must be enabled"
   }
   
   # Bad ❌ - tests multiple things
   assert {
     condition     = aws_s3_bucket.this.bucket != "" && aws_s3_bucket.this.versioning.enabled
     error_message = "Bucket validation failed"
   }
```

2. **Use descriptive run names**
```hcl
   # Good ✅
   run "validate_kms_encryption_for_production" {
   
   # Bad ❌
   run "test1" {
```

3. **Write helpful error messages**
```hcl
   # Good ✅
   error_message = "Backup retention must be at least 7 days for compliance"
   
   # Bad ❌
   error_message = "Invalid value"
```

4. **Test edge cases and conditionals**
```hcl
   run "validate_versioning_enabled" {
     variables {
       enable_versioning = true
     }
     assert {
       condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
       error_message = "Versioning must be enabled when enable_versioning is true"
     }
   }
   
   run "validate_versioning_suspended" {
     variables {
       enable_versioning = false
     }
     assert {
       condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Suspended"
       error_message = "Versioning must be suspended when enable_versioning is false"
     }
   }
```

### Adding Tests for New Modules

1. **Create test directory**
```bash
   mkdir -p modules/{module_name}/tests
```

2. **Create test files** (use existing modules as templates)
```bash
   touch modules/{module_name}/tests/{module}_basic.tftest.hcl
   touch modules/{module_name}/tests/{module}_security.tftest.hcl
   touch modules/{module_name}/tests/{module}_tagging.tftest.hcl
```

3. **Add to workflow** (`.github/workflows/terraform-tests.yml`)
   - Add path filter
   - Add test job
   - Add to test summary

4. **Test locally before committing**
```bash
   cd modules/{module_name}
   terraform init
   terraform test -verbose
```

## Troubleshooting

### Common Issues

#### Test Failure: "Resource not found"

**Problem**: Test references a resource that doesn't exist in the module

**Solution**: Check resource names in `main.tf`
```bash
cd modules/{module}
grep "resource \"" main.tf
```

#### Test Failure: "Tag missing"

**Problem**: Expected tag not present on resource

**Solution**: Verify tags in module code
```hcl
# Check if tags are defined in variables.tf
# Check if tags are applied in main.tf via local.common_tags or var.tags
```

#### Test Failure: "Invalid value"

**Problem**: Variable validation failed

**Solution**: Check variable constraints in `variables.tf`
```hcl
variable "tags" {
  validation {
    condition = alltrue([
      contains(keys(var.tags), "Environment"),
      # ... other required keys
    ])
    error_message = "Tags must include all mandatory fields."
  }
}
```

#### Format Check Failed

**Problem**: `terraform fmt -check` failed in CI

**Solution**: Format your code
```bash
cd modules/{module}
terraform fmt -recursive
git add .
git commit -m "Fix formatting"
```

#### Init Failed in CI

**Problem**: Terraform initialization failed

**Solution**: Check for syntax errors
```bash
cd modules/{module}
terraform init
terraform validate
```

### Debugging Test Failures

1. **Run tests locally with verbose output**
```bash
   terraform test -verbose 2>&1 | tee test-debug.log
```

2. **Check specific test file**
```bash
   terraform test -filter=tests/failing_test.tftest.hcl -verbose
```

3. **Review terraform plan output**
```bash
   terraform init
   terraform plan
```

4. **Check variable defaults**
   - Review `variables.tf` for default values
   - Ensure test variables match required schema

5. **Verify resource references**
   - Check resource type and name match `main.tf`
   - For `for_each` resources, use correct key reference

## Test Coverage Goals

### Current Coverage

| Module | Basic Tests | Security Tests | Tagging Tests | Total Assertions |
|--------|-------------|----------------|---------------|------------------|
| S3 | ✅ 8 | ✅ 9 | ✅ 8 | 25 |
| RDS | ✅ 12 | ✅ 15 | ✅ 12 | 39+ |
| aws_mq_broker | ⏳ Pending | ⏳ Pending | ⏳ Pending | 0 |
| runner-iam | ⏳ Pending | ⏳ Pending | ⏳ Pending | 0 |

### Required Test Coverage

All modules must have tests for:

**Basic Tests:**
- ✅ Resource creation
- ✅ Naming conventions
- ✅ Configuration defaults
- ✅ Conditional logic

**Security Tests:**
- ✅ Encryption at rest
- ✅ Encryption in transit
- ✅ Access controls
- ✅ Backup configuration
- ✅ Monitoring enabled
- ✅ Network security

**Tagging Tests:**
- ✅ Required tags present
- ✅ Tag values match variables
- ✅ Environment-specific tags
- ✅ Tag merging from var.tags

## Migration from Terratest

The S3 module previously used Terratest (`s3_test.go`). These files have been archived in `modules/s3/tests/archive/`.

**Why we moved to native Terraform tests:**
- ✅ No Go dependency or module management
- ✅ Faster test execution
- ✅ Easier to write and maintain
- ✅ Better integration with Terraform workflow
- ✅ Lower barrier to entry for contributors

**When to use Terratest:**
- Complex integration scenarios
- Actual resource deployment validation
- Cross-module dependency testing
- End-to-end infrastructure validation

For now, focus on native Terraform tests. Terratest may be reintroduced later for integration testing.

## Compliance Validation

Tests ensure compliance with:

### Security Standards
- All S3 buckets must block public access
- All storage must be encrypted (KMS or AES256)
- RDS instances must not be publicly accessible
- Backups must be retained ≥7 days
- CloudWatch monitoring must be enabled

### Tagging Standards
- Required tags: Environment, Project, ManagedBy, source-repo
- Environment values: sandbox, test, prelive, live
- Additional mandatory tags (cost-centre, account-code, etc.)

### Infrastructure Standards
- Multi-AZ enabled for live environments
- Deletion protection for production databases
- Versioning enabled for S3 buckets (configurable)
- Final snapshots required for production RDS

## Quick Reference

### Run All Tests
```bash
# S3
cd modules/s3 && terraform test

# RDS
cd modules/rds && terraform test
```

### Run Specific Test
```bash
terraform test -filter=tests/{test_file}.tftest.hcl
```

### Debug Test
```bash
terraform test -verbose
```

### Format Code
```bash
terraform fmt -recursive
```

### Validate Syntax
```bash
terraform init && terraform validate
```

## Getting Help

- **CI/CD failing?** Check test logs in GitHub Actions artifacts
- **Local test failing?** Run with `-verbose` flag
- **Unsure what to test?** Review existing test files as templates
- **Need assistance?** Ask in the platform engineering Slack channel

## References

- [Terraform Test Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Terraform Test Command](https://developer.hashicorp.com/terraform/cli/commands/test)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Core Cloud Standards](link-to-internal-standards)

---

**Last Updated**: 2024-02
**Maintained By**: Platform Engineering Team
```

---
