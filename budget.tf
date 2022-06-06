resource "aws_budgets_budget" "budget" {
  count = local.budget == null ? 0 : 1

  name              = "${local.prefix}-budget-monthly"
  budget_type       = "COST"
  limit_amount      = local.budget.limit_monthly_dollar
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2022-01-01_00:00"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.email]
  }
}
