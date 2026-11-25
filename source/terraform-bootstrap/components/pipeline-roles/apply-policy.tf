data "aws_iam_policy_document" "apply" {
  statement {
    sid       = "ListState"
    actions   = ["s3:ListBucket"]
    resources = [local.state_bucket_arn]
  }

  statement {
    sid       = "ReadWriteState"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = local.state
  }

  statement {
    sid       = "DenyOwnState"
    effect    = "Deny"
    actions   = ["s3:*Object"]
    resources = local.own_state
  }
}
