# WordPress Site

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
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | 4.3.1 |
| <a name="module_asg"></a> [asg](#module\_asg) | terraform-aws-modules/autoscaling/aws | 6.5.3 |
| <a name="module_asg_iam_policy"></a> [asg\_iam\_policy](#module\_asg\_iam\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | 5.9.2 |
| <a name="module_asg_security_group"></a> [asg\_security\_group](#module\_asg\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_efs"></a> [efs](#module\_efs) | terraform-aws-modules/efs/aws | 1.1.1 |
| <a name="module_efs_security_group"></a> [efs\_security\_group](#module\_efs\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_lb_security_group"></a> [lb\_security\_group](#module\_lb\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | terraform-aws-modules/alb/aws | 8.2.1 |
| <a name="module_memcached"></a> [memcached](#module\_memcached) | flaudisio/elasticache/aws//modules/memcached | 0.1.1 |
| <a name="module_memcached_security_group"></a> [memcached\_security\_group](#module\_memcached\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds/aws | 5.2.3 |
| <a name="module_rds_security_group"></a> [rds\_security\_group](#module\_rds\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | flaudisio/standard-tags/aws | 0.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route53_record.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.memcached](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.rds_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ami.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_default_tags.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.asg_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_route53_zone_id"></a> [account\_route53\_zone\_id](#input\_account\_route53\_zone\_id) | The ID of the account's Route 53 zone | `string` | n/a | yes |
| <a name="input_account_route53_zone_name"></a> [account\_route53\_zone\_name](#input\_account\_route53\_zone\_name) | The name of the account's Route 53 zone | `string` | n/a | yes |
| <a name="input_db_instance_type"></a> [db\_instance\_type](#input\_db\_instance\_type) | The type of the DB instance | `string` | n/a | yes |
| <a name="input_db_subnet_group"></a> [db\_subnet\_group](#input\_db\_subnet\_group) | The name of the DB subnet group | `string` | n/a | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | The type of the EC2 instances | `string` | n/a | yes |
| <a name="input_ec2_public_key"></a> [ec2\_public\_key](#input\_ec2\_public\_key) | The SSH public key material to be configured in EC2 instances | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_memcached_instance_type"></a> [memcached\_instance\_type](#input\_memcached\_instance\_type) | The type of the ElastiCache/Memcached instance | `string` | n/a | yes |
| <a name="input_memcached_subnet_group"></a> [memcached\_subnet\_group](#input\_memcached\_subnet\_group) | The name of the ElastiCache subnet group to be used by the Memcached cluster | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The team that owns this WordPress site | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnet IDs to deploy the instances to | `list(string)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnet IDs to deploy the load balancer to | `list(string)` | n/a | yes |
| <a name="input_site_name"></a> [site\_name](#input\_site\_name) | The name of the site | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_allow_vpc_access"></a> [allow\_vpc\_access](#input\_allow\_vpc\_access) | Whether to allow any VPC-originating access to private resources. Only enable for debugging purposes! | `bool` | `false` | no |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | The desired capacity of the auto scaling group | `number` | `1` | no |
| <a name="input_asg_health_check_type"></a> [asg\_health\_check\_type](#input\_asg\_health\_check\_type) | The mode the ASG health checking is done | `string` | `"ELB"` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | The maximum site of the auto scaling group | `number` | `1` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | The minimum site of the auto scaling group | `number` | `1` | no |
| <a name="input_db_multi_az"></a> [db\_multi\_az](#input\_db\_multi\_az) | Whether to enable multi-AZ deployment of the database | `bool` | `true` | no |
| <a name="input_db_skip_final_snapshot"></a> [db\_skip\_final\_snapshot](#input\_db\_skip\_final\_snapshot) | Whether to enable multi-AZ deployment of the database | `bool` | `false` | no |
| <a name="input_ec2_ami_architecture"></a> [ec2\_ami\_architecture](#input\_ec2\_ami\_architecture) | The architecture of the AMI used to deploy the EC2 instances | `string` | `"x86_64"` | no |
| <a name="input_ec2_ami_name"></a> [ec2\_ami\_name](#input\_ec2\_ami\_name) | The name of the AMI used to deploy the EC2 instances | `string` | `"ubuntu-minimal/images/*ubuntu-jammy-22.04-*-minimal-20230213"` | no |
| <a name="input_ec2_ami_owner"></a> [ec2\_ami\_owner](#input\_ec2\_ami\_owner) | The owner of the AMI used to deploy the EC2 instances | `string` | `"099720109477"` | no |
| <a name="input_memcached_multi_az"></a> [memcached\_multi\_az](#input\_memcached\_multi\_az) | Whether the Memcached nodes should be created across multiple AZs. Requires `memcached_num_nodes > 1` | `bool` | `false` | no |
| <a name="input_memcached_num_nodes"></a> [memcached\_num\_nodes](#input\_memcached\_num\_nodes) | The initial number of cache nodes that the cache cluster will have; must be between 1 and 40. If this number is reduced on subsequent runs, the highest numbered nodes will be removed | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_endpoint"></a> [app\_endpoint](#output\_app\_endpoint) | The endpoint of the application |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | The name of the Auto Scaling Group |
| <a name="output_db_address"></a> [db\_address](#output\_db\_address) | The address of the database instance |
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | The endpoint of the database instance |
| <a name="output_efs_endpoint"></a> [efs\_endpoint](#output\_efs\_endpoint) | The endpoint of the provisioned EFS file system |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | The DNS name of the load balancer |
| <a name="output_memcached_address"></a> [memcached\_address](#output\_memcached\_address) | The DNS name of the Memcached cluster without the port appended |
| <a name="output_memcached_endpoint"></a> [memcached\_endpoint](#output\_memcached\_endpoint) | The endpoint of the Memcached cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
