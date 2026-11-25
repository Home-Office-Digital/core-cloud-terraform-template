data "aws_iam_policy_document" "plan" {
  statement {
    sid       = "ListState"
    actions   = ["s3:ListBucket"]
    resources = [local.state_bucket_arn]
  }

  statement {
    sid       = "ReadState"
    actions   = ["s3:GetObject"]
    resources = local.state
  }

  statement {
    sid       = "LockState"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = local.state_locks
  }

  # Init creates each PR's workspace by writing an empty state object, and runs
  # as this role. Real state stays read-only.
  dynamic "statement" {
    for_each = var.apply_from_default_branch ? [1] : []
    content {
      sid       = "CreateEphemeralState"
      actions   = ["s3:PutObject"]
      resources = [local.ephemeral_state]
    }
  }

  statement {
    sid       = "DenyOwnState"
    effect    = "Deny"
    actions   = ["s3:*Object"]
    resources = local.own_state
  }
}
