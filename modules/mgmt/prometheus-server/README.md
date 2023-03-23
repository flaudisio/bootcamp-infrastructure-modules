# Prometheus Server

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_asg"></a> [asg](#module\_asg) | terraform-aws-modules/autoscaling/aws | 6.5.3 |
| <a name="module_asg_iam_policy"></a> [asg\_iam\_policy](#module\_asg\_iam\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | 5.11.2 |
| <a name="module_asg_security_group"></a> [asg\_security\_group](#module\_asg\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | flaudisio/standard-tags/aws | 0.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_timestreamwrite_database.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/timestreamwrite_database) | resource |
| [aws_timestreamwrite_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/timestreamwrite_table) | resource |
| [aws_ami.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_default_tags.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.asg_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of the EC2 instances | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnet IDs to deploy the containers to | `list(string)` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The SSH public key material to be configured in EC2 instances | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_allow_vpc_access"></a> [allow\_vpc\_access](#input\_allow\_vpc\_access) | Whether to allow any VPC-originating access to private resources. Only enable for debugging purposes! | `bool` | `false` | no |
| <a name="input_ami_architecture"></a> [ami\_architecture](#input\_ami\_architecture) | The architecture of the AMI used to deploy the EC2 instances | `string` | `"x86_64"` | no |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | The name of the AMI used to deploy the EC2 instances | `string` | `"ubuntu-base-22.04-*"` | no |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | The owner of the AMI used to deploy the EC2 instances | `string` | `"self"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | The number of EC2 instances to launch | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | The name of the Auto Scaling Group |
| <a name="output_asg_security_group_id"></a> [asg\_security\_group\_id](#output\_asg\_security\_group\_id) | The ID of the security group attached to the EC2 instances |
| <a name="output_timestream_database_arn"></a> [timestream\_database\_arn](#output\_timestream\_database\_arn) | The ARN of the Timestream database |
| <a name="output_timestream_database_name"></a> [timestream\_database\_name](#output\_timestream\_database\_name) | The name of the Timestream database |
| <a name="output_timestream_table_arn"></a> [timestream\_table\_arn](#output\_timestream\_table\_arn) | The ARN of the Timestream table |
| <a name="output_timestream_table_name"></a> [timestream\_table\_name](#output\_timestream\_table\_name) | The name of the Timestream table |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
