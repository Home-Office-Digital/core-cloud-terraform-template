mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }
}

variables {
  environment  = "development"
  project_name = "example"
  tags = {
    cost-centre      = "x"
    account-code     = "x"
    portfolio-id     = "x"
    project-id       = "x"
    service-id       = "x"
    environment-type = "x"
    owner-business   = "x"
    budget-holder    = "x"
    source-repo      = "x"
    hosting-platform = "x"
  }
}

run "plans_with_valid_inputs" {
  command = plan

  assert {
    condition     = output.account_id == "123456789012"
    error_message = "account_id must report the account the provider authenticated to."
  }
}

run "rejects_unknown_environment" {
  command = plan

  variables {
    environment = "production"
  }

  expect_failures = [var.environment]
}

run "rejects_empty_mandatory_tag" {
  command = plan

  variables {
    tags = merge(var.tags, { cost-centre = "" })
  }

  expect_failures = [var.tags]
}
