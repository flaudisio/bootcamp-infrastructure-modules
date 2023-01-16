# Ansible Semaphore EC2 Instance

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_iam_policy"></a> [ec2\_iam\_policy](#module\_ec2\_iam\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | 5.9.2 |
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | terraform-aws-modules/ec2-instance/aws | 4.2.1 |
| <a name="module_ec2_security_group"></a> [ec2\_security\_group](#module\_ec2\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route53_record.endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.semaphore_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.semaphore_credentials](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_route53_zone_id"></a> [account\_route53\_zone\_id](#input\_account\_route53\_zone\_id) | The ID of the account's Route 53 zone | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of the EC2 instance | `string` | n/a | yes |
| <a name="input_private_subnet_id"></a> [private\_subnet\_id](#input\_private\_subnet\_id) | The ID of the private subnet where the instance will be deployed on | `string` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The SSH public key material to be configured in the EC2 instance | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_allow_ssh_from_cidrs"></a> [allow\_ssh\_from\_cidrs](#input\_allow\_ssh\_from\_cidrs) | A list of CIDRs to be allowed to access the SSH port of the instance | `list(string)` | `[]` | no |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | The name of the AMI to be used for the instance | `string` | `"ubuntu-minimal/images/*ubuntu-jammy-22.04-*-minimal-20221208"` | no |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | The owner of the AMI to be used for the instance | `string` | `"099720109477"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The ID of the EC2 instance |
| <a name="output_instance_private_ip"></a> [instance\_private\_ip](#output\_instance\_private\_ip) | The private IP of the EC2 instance |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the instance's security group |
| <a name="output_semaphore_credentials_ssm_parameters"></a> [semaphore\_credentials\_ssm\_parameters](#output\_semaphore\_credentials\_ssm\_parameters) | The SSM parameters that store Semaphore credentials |
| <a name="output_semaphore_endpoint"></a> [semaphore\_endpoint](#output\_semaphore\_endpoint) | The endpoint of the Semaphore server |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
