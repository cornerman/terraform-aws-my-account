module "permission_sets" {
  count = local.sso == null ? 0 : 1

  source  = "cloudposse/sso/aws//modules/permission-sets"
  version = "0.6.2"

  permission_sets = concat(
    [{
      name               = local.sso_admin_permission_set
      description        = "Allow Full Access to the account"
      relay_state        = ""
      session_duration   = ""
      tags               = {}
      inline_policy      = ""
      policy_attachments = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }]
  )
}

module "sso_account_assignments" {
  count = local.sso == null ? 0 : 1

  source  = "cloudposse/sso/aws//modules/account-assignments"
  version = "0.6.2"

  account_assignments = concat(
    [for sub_account, opts in var.sub_accounts : {
      account             = aws_organizations_account.sub_account[sub_account].id
      permission_set_arn  = module.permission_sets[0].permission_sets[local.sso_admin_permission_set].arn
      permission_set_name = local.sso_admin_permission_set
      principal_type      = "GROUP"
      principal_name      = local.sso_admin_group_name
    }],
    [{
      account             = data.aws_caller_identity.current.account_id
      permission_set_arn  = module.permission_sets[0].permission_sets[local.sso_admin_permission_set].arn
      permission_set_name = local.sso_admin_permission_set
      principal_type      = "GROUP"
      principal_name      = local.sso_admin_group_name
    }]
  )
}

