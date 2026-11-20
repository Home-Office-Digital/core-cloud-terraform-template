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

  statement {
    sid       = "DenyOwnState"
    effect    = "Deny"
    actions   = ["s3:*Object"]
    resources = local.own_state
  }
}
