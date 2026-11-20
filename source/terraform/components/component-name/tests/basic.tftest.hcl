mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

variables {
  environment        = "dev"
  project_name       = "example"
  notification_email = "team@example.com"
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
    condition     = local.name_prefix == "example-dev"
    error_message = "Resource names must start with <project_name>-<environment>."
  }
}

run "rejects_empty_mandatory_tag" {
  command = plan

  variables {
    tags = merge(var.tags, { cost-centre = "" })
  }

  expect_failures = [var.tags]
}
