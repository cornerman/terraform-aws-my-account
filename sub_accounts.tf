resource "aws_iam_account_alias" "alias" {
  count         = var.name == null ? 0 : 1
  account_alias = var.name
}

resource "aws_organizations_organization" "organization" {
  aws_service_access_principals = [
    "sso.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]

  feature_set = "ALL"
}

resource "aws_organizations_account" "sub_account" {
  for_each  = var.sub_accounts
  name      = each.key
  email     = each.value.email
  role_name = local.account_role_name

  close_on_deletion = each.value.close_on_deletion

  # https://github.com/hashicorp/terraform-provider-aws/issues/8947
  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}
