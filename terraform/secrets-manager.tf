locals {
  managed_secrets = {
    for key, cfg in var.managed_secrets : key => {
      description                      = try(cfg.description, null)
      secret_name                      = coalesce(try(cfg.secret_name, null), "${var.project_name}-${key}")
      kms_key_id                       = try(cfg.kms_key_id, null)
      recovery_window_in_days          = try(cfg.recovery_window_in_days, 30)
      mode                             = try(cfg.mode, "empty")
      random_password_length           = try(cfg.random_password_length, 32)
      random_password_special          = try(cfg.random_password_special, true)
      random_password_override_special = try(cfg.random_password_override_special, "!#$%&*()-_=+[]{}<>:?")
      secret_string_template           = try(cfg.secret_string_template, {})
      tags                             = try(cfg.tags, {})
    }
  }

  generated_secrets = {
    for key, cfg in local.managed_secrets : key => cfg if cfg.mode == "generated"
  }

  existing_secret_names = {
    for name in var.existing_secret_names : name => name
  }
}

resource "aws_secretsmanager_secret" "managed" {
  for_each = local.managed_secrets

  name                    = each.value.secret_name
  description             = each.value.description
  kms_key_id              = each.value.kms_key_id
  recovery_window_in_days = each.value.recovery_window_in_days

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = each.value.secret_name
    }
  )
}

resource "random_password" "generated" {
  for_each = local.generated_secrets

  length           = each.value.random_password_length
  special          = each.value.random_password_special
  override_special = each.value.random_password_override_special
}

resource "aws_secretsmanager_secret_version" "generated" {
  for_each = local.generated_secrets

  secret_id = aws_secretsmanager_secret.managed[each.key].id
  secret_string = jsonencode(merge(
    each.value.secret_string_template,
    {
      password = random_password.generated[each.key].result
    }
  ))
}

data "aws_secretsmanager_secret" "existing" {
  for_each = local.existing_secret_names

  name = each.key
}

data "aws_secretsmanager_secret_version" "existing" {
  for_each = data.aws_secretsmanager_secret.existing

  secret_id = each.value.id
}

locals {
  existing_secret_strings = {
    for name, version in data.aws_secretsmanager_secret_version.existing : name => version.secret_string
  }

  existing_secret_json = {
    for name, secret_string in local.existing_secret_strings : name => try(jsondecode(secret_string), null)
  }

  # Example consumer: use the decoded JSON to feed username/password into aws_db_instance or another resource.
  rds_secret_example = var.example_rds_secret_name == null ? null : try(local.existing_secret_json[var.example_rds_secret_name], null)
}
