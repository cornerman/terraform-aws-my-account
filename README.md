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

You can of course also use your existing AWS account, but it is a good start to clean with a clean root account for management and then have sub-accounts for specific use-cases. See at the bottom of the readme, how to import existing accounts.

Enable MFA for your root user for your own security - this is seriously important. Click this link and expand the Multi-Factor-Authentication tab: https://console.aws.amazon.com/iam/home#/security_credentials

#### Initial Access

Manually create an IAM user with admin access and get the security credentials (you should delete this user afterwards) _or_ once add security credentials to the root user (and remove them afterwards).

Set the AWS credentials for this user in your terminal (e.g. environment variable `AWS_PROFILE` or `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`/`AWS_REGION`).

```sh
export AWS_ACCESS_KEY_ID="MY_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="MY_SECRET_ACCESS_KEY"
export AWS_REGION=eu-central-1
```

After your have deployed this module once, you will use a different way of authenticating using AWS SSO (see later).

#### Setup

Go into or copy the `./example` directroy.

Then create a terraform state bucket and a terraform dynamodb lock table:

```sh
./initital_setup.sh
```

#### SSO

Manual steps needed to prepare SSO:

- Enable SSO in your AWS account: https://console.aws.amazon.com/singlesignon/identity/home
  - confirm when being asked to enable the management of aws organizations in your account
  - make AWS "Identity Center directory" your identity source
- Enable MFA in AWS SSO: https://console.aws.amazon.com/singlesignon/identity/home#!/settings/mfa
- Create an identity group called "Administrators" in AWS SSO: https://console.aws.amazon.com/singlesignon/identity/home#!/groups/create
- Create an identity user for yourself and add it to the Administrators group (you can add other people as well and invite them to work with you): https://eu-central-1.console.aws.amazon.com/singlesignon/identity/home?region=eu-central-1#!/users$addUserWizard

### Deploy

Deploy this terraform module:

Edit the `example/main.tf` of this repo accordingly with the names you want to use.

```sh
terraform init
terraform apply
```

At this point you will most likely run into an error like this.

```text
module.my_account.aws_organizations_organization.organization: Creating...
╷
│ Error: Error creating organization: AlreadyInOrganizationException: The AWS account is already a member of an organization.
│
│   with module.my_account.aws_organizations_organization.organization,
│   on ../sub_accounts.tf line 6, in resource "aws_organizations_organization" "organization":
│    6: resource "aws_organizations_organization" "organization" {
│
╵
```

This is expected since we already created an aws-organization above. To fix it we need get the organization id and import it to terraform.

```sh
aws organizations describe-organization | jq -r ".Organization.Id"
# YOUR_ID

terraform import module.my_account.aws_organizations_organization.organization YOUR_ID
```

After a successful import you can run `terraform apply` again.

As output, you will get the aws config for your whole AWS account including the SSO login and role assumption into your sub-accounts. It will look similar to this:

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

aws_config = <<EOT

# This should go into your ~/.aws/config.
# Then you can use `export AWS_PROFILE=my-account-name` to work with the aws-cli.
# You will need to install aws-vault.

[profile my-account-name_sso]
sso_start_url = https://d-xxxxxxxxxx.awsapps.com/start
sso_region = eu-central-1
sso_account_id = 000000000000
sso_role_name = AdministratorAccess
region = eu-central-1
output = json

[profile my-account-name]
region = eu-central-1
output = json
credential_process = aws-vault exec my-account-name_sso --json

[profile my-account-name-sandbox]
role_arn = arn:aws:iam::111111111111:role/OrganizationAccountAccessRole
source_profile = my-account-name
region = eu-central-1

[profile my-account-name-my-project]
role_arn = arn:aws:iam::222222222222:role/OrganizationAccountAccessRole
source_profile = my-account-name
region = eu-central-1

EOT
```

The url `https://d-xxxxxxxxxx.awsapps.com/start` is now your login url to get access to the browser console.

## Tips and Tricks

### Import an existing AWS account into the Organization

Say you have an existing AWS account and want to use it inside this module.

First go into AWS and follow the steps to import an account into your now existing AWS organization. You can invite an account id and then accept the invitation inside the other account. [see aws documentation](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_invites.html) Accepting the invite has to happen in the old account, so remember to log out of the current account (or open the aws console for the old account in a private browsing session).

Then change your terraform code to how you want your sub_accounts to look with the imported account:

```tf
module "my_account" {
  source  = "cornerman/my-account/aws"
  version = "0.1.0"

  name  = "my-account-name"
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
    my-imported-account = {
      email             = "<email address of the root user of that account>"
      close_on_deletion = false
    }
  }
}
```

Then run terraform to let terraform know that this account already exists and should not be created:

```shell
terraform import 'module.my_account.aws_organizations_account.sub_account["my-imported-account"]' <account id of the old account>
```

From there on, you can run `terraform apply` to completely setup the new account. Check out the terraform plan to see whether everything worked as expected.
