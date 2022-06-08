output "aws_config" {
  value = <<EOT

# This should go into your ~/.aws/config.
# Then you can use `export AWS_PROFILE=${var.name}` to work with the aws-cli.
# You will need to install aws-vault.

[profile ${var.name}_sso]
sso_start_url = https://${one(data.aws_ssoadmin_instances.current.identity_store_ids)}.awsapps.com/start
sso_region = ${data.aws_region.current.name}
sso_account_id = ${data.aws_caller_identity.current.account_id}
sso_role_name = AdministratorAccess
region = ${data.aws_region.current.name}
output = json

[profile ${var.name}]
region = ${data.aws_region.current.name}
output = json
credential_process = aws-vault exec ${var.name}_sso --json

${join("\n", [for sub_account in aws_organizations_account.sub_account : <<EOI
[profile ${var.name}-${sub_account.name}]
role_arn = arn:aws:iam::${sub_account.id}:role/${local.account_role_name}
source_profile = ${var.name}
region = ${data.aws_region.current.name}
EOI
])}
EOT
}
