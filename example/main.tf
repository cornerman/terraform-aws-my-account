module "my_account" {
  # source  = "cornerman/my-account/aws"
  # version = "0.1.0"
  source = "../"

  name  = "johannes-private"
  email = "aws@johannes.karoff.net"

  budget = {
    limit_monthly_dollar = 10
  }

  sso = {
  }

  sub_accounts = {
    sandbox = {
      email             = "aws.sandbox@johannes.karoff.net"
      close_on_deletion = false
    }
    issue_tracker = {
      email             = "aws.issue-tracker@johannes.karoff.net"
      close_on_deletion = false
    }
    artifacts = {
      email             = "aws.artifacts@johannes.karoff.net"
      close_on_deletion = false
    }
  }
}
