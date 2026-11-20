mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

# core-cloud-iam-role-tf-module 0.2.8 declares its own provider "aws" block,
# which mock_provider can't reach, so its outputs are stubbed instead.
override_module {
  target = module.plan_role
  outputs = {
    name = "example-plan"
    arn  = "arn:aws:iam::123456789012:role/example-plan"
  }
}

override_module {
  target = module.apply_role
  outputs = {
    name = "example-apply"
    arn  = "arn:aws:iam::123456789012:role/example-apply"
  }
}

variables {
  environment               = "release"
  github_repository         = "Home-Office-Digital/example-repo"
  plan_role_name            = "example-plan"
  apply_role_name           = "example-apply"
  permissions_boundary_name = "example-boundary"
  state_bucket_name         = "example-tfstate"
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

run "plan_role_trusts_only_this_repo" {
  command = plan

  assert {
    condition     = local.plan_subjects == ["repo:Home-Office-Digital/example-repo:*"]
    error_message = "The plan role must trust any ref of this repo and nothing else."
  }
}

run "apply_role_trusts_only_its_environment" {
  command = plan

  assert {
    condition     = local.apply_subjects == ["repo:Home-Office-Digital/example-repo:environment:release"]
    error_message = "The apply role must trust only the GitHub Environment it deploys to."
  }
}

run "apply_role_trusts_main_when_enabled" {
  command = plan

  variables {
    environment               = "development"
    apply_from_default_branch = true
  }

  assert {
    condition = local.apply_subjects == [
      "repo:Home-Office-Digital/example-repo:environment:development",
      "repo:Home-Office-Digital/example-repo:ref:refs/heads/main",
    ]
    error_message = "With apply_from_default_branch set, the apply role must also trust main."
  }
}

run "roles_cannot_touch_bootstrap_state" {
  command = plan

  assert {
    condition = alltrue([
      for statements in [data.aws_iam_policy_document.plan.statement, data.aws_iam_policy_document.apply.statement] : anytrue([
        for s in statements :
        s.effect == "Deny"
        && s.actions == toset(["s3:*Object"])
        && s.resources == toset(["arn:aws:s3:::example-tfstate/example-repo/source/terraform-bootstrap/*"])
      ])
    ])
    error_message = "Both policies must deny s3:*Object on this folder's state."
  }
}

run "plan_role_is_read_only" {
  command = plan

  assert {
    condition = one([
      for s in data.aws_iam_policy_document.plan.statement : s.resources if s.sid == "LockState"
    ]) == toset(["arn:aws:s3:::example-tfstate/example-repo/*.tflock", "arn:aws:s3:::example-tfstate/env:example-repo/*.tflock"])
    error_message = "LockState must cover only this repo's state lock files."
  }

  assert {
    condition = alltrue(flatten([
      for s in data.aws_iam_policy_document.plan.statement : [
        for a in s.actions : can(regex("^[a-z0-9-]+:(Get|List|Describe)", a))
      ] if s.effect != "Deny" && s.sid != "LockState"
    ]))
    error_message = "plan-policy.tf may only allow Get*, List* and Describe* actions, apart from LockState. Put write actions in apply-policy.tf."
  }
}

run "rejects_invalid_github_repository" {
  command = plan

  variables {
    github_repository = "example-repo"
  }

  expect_failures = [var.github_repository]
}

run "rejects_invalid_role_name" {
  command = plan

  variables {
    plan_role_name = "<plan-role-name>"
  }

  expect_failures = [var.plan_role_name]
}

run "rejects_empty_mandatory_tag" {
  command = plan

  variables {
    tags = merge(var.tags, { cost-centre = "" })
  }

  expect_failures = [var.tags]
}
