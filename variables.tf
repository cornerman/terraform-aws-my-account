variable "name" {
  description = "iam account alias"
  type        = string
  default     = null
}

variable "email" {
  description = "get notification about budgets and alarms to this email"
  type        = string
}

variable "budget" {
  description = "create a budget with email notification for this account"
  type = object({
    limit_monthly_dollar = string
  })
  default = null
}

variable "sub_accounts" {
  description = "create sub accounts for projects"
  type = map(object({
    email             = string
    close_on_deletion = bool
  }))
  default = {}
}

locals {
  prefix = "my-account"

  budget = var.budget == null ? null : defaults(var.budget, {
  })

  sub_accounts = var.sub_accounts == null ? null : defaults(var.sub_accounts, {
  })

  account_role_name = "OrganizationAccountAccessRole"

  sso_admin_group_name     = "Administrators"
  sso_admin_permission_set = "AdministratorAccess"
}
