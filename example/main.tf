module "my_account" {
  # source  = "cornerman/my-account/aws"
  # version = "0.1.0"
  source = "../"

  name  = "johannes-private"
  email = "me@example.com"

  budget = {
    limit_monthly_dollar = 10
  }

  sub_accounts = {
    sandbox = {
      email             = "me+sandbox@example.com"
      close_on_deletion = true
    }
    my-project = {
      email             = "me.my-project@example.com"
      close_on_deletion = false
    }
  }
}
