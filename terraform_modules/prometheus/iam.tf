data "aws_iam_policy_document" "this_role_policy" {
  for_each = var.iam_policy

  statement {
    effect    = each.value.effect
    actions   = each.value.actions
    resources = each.value.resources
  }
}

data "aws_iam_policy_document" "this_assume_role_policy" {
  statement {
    actions = var.iam_assume_role_policy.actions

    dynamic "principals" {
      for_each = var.iam_assume_role_policy.principals

      content {
        type        = principals.value.type
        identifiers = principals.value.identifiers
      }

    }
  }
}

resource "aws_iam_policy" "this" {
  for_each = var.iam_policy

  name   = each.key
  policy = data.aws_iam_policy_document.this_role_policy[each.key].json

  tags = var.tags
}

resource "aws_iam_role" "this" {
  name = var.iam_role_name

  assume_role_policy = data.aws_iam_policy_document.this_assume_role_policy.json

  managed_policy_arns = concat([for policy_name, policy in aws_iam_policy.this : policy.arn], var.iam_additional_policies)

  tags = var.tags
}
