# my-account

Basic things to setup your AWS account.

This module is for you, if you want an easy way to bootstrap your AWS account with a few sane defaults.
- You will get a declarative way to define your budget (and get email alerts when spending too much).
- You can easily setup and remove new sub-accounts for your different projects (sets up an AWS organization for you).
- You get a secure way of logging into your AWS accounts without ever using long-lived credentials on IAM users (basic AWS SSO).

## Requirements

- terraform (>= 1.0.0)
- Recommended: [aws-vault](https://github.com/99designs/aws-vault)

## How to use?

Usage example (see also the complete [example](./example/main.tf)):
```tf
module "my_account" {
  source  = "cornerman/my-account/aws"
  version = "0.1.0"

  name  = "my-account-name"
  email = "me@example.com"

  budget = {
    limit_monthly_dollar = 10
  }

  sso = {
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
```

### Initial setup

#### AWS Account Creation

Create a new AWS account: https://portal.aws.amazon.com/billing/signup

Enable MFA for your root user for your own security - this is seriously important. Click this link and expand the Multi-Factor-Authentication tab: https://console.aws.amazon.com/iam/home#/security_credentials

#### Initial Access

Manually create an IAM user with admin access and get the security credentials (you should delete this user afterwards) or once add security credentials to the root user (and remove them again).

Set the AWS credentials for this user in your terminal (e.g. environment variable `AWS_PROFILE` or `AWS_ACCESS_KEY`/`AWS_SECRET_ACCESS_KEY`/`AWS_REGION`). After your have deployed this module once, you will use a different way of authenticating using AWS SSO (see later).

#### Setup

Go into the `./example` folder.

Then create a terraform state bucket and a terraform dynamodb lock table:
```sh
./initital_setup.sh
```

#### SSO

Manual steps needed to prepare SSO:
- Enable SSO in your AWS account: https://console.aws.amazon.com/singlesignon/identity/home
- Create an identity group called "Administrators" in AWS SSO: https://console.aws.amazon.com/singlesignon/identity/home#!/groups/create
- Enable MFA in AWS SSO: https://console.aws.amazon.com/singlesignon/identity/home#!/settings/mfa

Afterwards you should add a user for yourself in AWS SSO and add it to the Administrators group. You can add other people as well and invite them to work with you.

### Deploy

Deploy this terraform module:
```sh
terraform init
terraform apply
```
