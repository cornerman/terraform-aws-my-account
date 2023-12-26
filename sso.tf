module "permission_sets" {
  source  = "cloudposse/sso/aws//modules/permission-sets"
  version = "0.7.1"

  permission_sets = concat(
    [{
      name               = local.sso_admin_permission_set
      description        = "Allow Full Access to the account"
      relay_state        = ""
      session_duration   = ""
      tags               = {}
      inline_policy      = ""
      policy_attachments = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      customer_managed_policy_attachments = []
    }]
  )
}

module "sso_account_assignments" {
  source  = "github.com/cornerman/terraform-aws-sso//modules/account-assignments?ref=c3a46b35409cce9c19f2bfbf393de1331ffc7685"

  account_assignments = concat(
    [for sub_account, opts in var.sub_accounts : {
      account_id          = aws_organizations_account.sub_account[sub_account].id
      account_key         = sub_account
      permission_set_arn  = module.permission_sets.permission_sets[local.sso_admin_permission_set].arn
      permission_set_name = local.sso_admin_permission_set
      principal_type      = "GROUP"
      principal_name      = local.sso_admin_group_name
    }],
    [{
      account_id          = data.aws_caller_identity.current.account_id
      account_key         = data.aws_caller_identity.current.account_id
      permission_set_arn  = module.permission_sets.permission_sets[local.sso_admin_permission_set].arn
      permission_set_name = local.sso_admin_permission_set
      principal_type      = "GROUP"
      principal_name      = local.sso_admin_group_name
    }]
  )
}


