# Ansible Semaphore on ECS

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
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | 4.3.1 |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | terraform-aws-modules/ecs/aws | 4.1.3 |
| <a name="module_ecs_task_iam_policy"></a> [ecs\_task\_iam\_policy](#module\_ecs\_task\_iam\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | 5.9.2 |
| <a name="module_ecs_task_iam_role"></a> [ecs\_task\_iam\_role](#module\_ecs\_task\_iam\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | 5.11.2 |
| <a name="module_ecs_task_security_group"></a> [ecs\_task\_security\_group](#module\_ecs\_task\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_lb_security_group"></a> [lb\_security\_group](#module\_lb\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | terraform-aws-modules/alb/aws | 8.2.1 |
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds/aws | 5.2.3 |
| <a name="module_rds_security_group"></a> [rds\_security\_group](#module\_rds\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | flaudisio/standard-tags/aws | 0.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_route53_record.load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.semaphore_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.semaphore_credentials](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_iam_policy_document.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_route53_zone_id"></a> [account\_route53\_zone\_id](#input\_account\_route53\_zone\_id) | The ID of the account's Route 53 zone | `string` | n/a | yes |
| <a name="input_account_route53_zone_name"></a> [account\_route53\_zone\_name](#input\_account\_route53\_zone\_name) | The name of the account's Route 53 zone | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region | `string` | n/a | yes |
| <a name="input_db_instance_type"></a> [db\_instance\_type](#input\_db\_instance\_type) | The type of the DB instance | `string` | n/a | yes |
| <a name="input_db_subnet_group"></a> [db\_subnet\_group](#input\_db\_subnet\_group) | The name of the DB subnet group | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnet IDs to deploy the instances to | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_allow_vpc_access"></a> [allow\_vpc\_access](#input\_allow\_vpc\_access) | Whether to allow VPC-originating access to private resources. Only enable for debugging purposes! | `bool` | `false` | no |
| <a name="input_attach_security_groups"></a> [attach\_security\_groups](#input\_attach\_security\_groups) | A list security groups to be attached to the instance | `list(string)` | `[]` | no |
| <a name="input_backup_bucket"></a> [backup\_bucket](#input\_backup\_bucket) | The name of an S3 bucket to be used to initialize the Semaphore database from a backup file | `string` | `null` | no |
| <a name="input_container_count"></a> [container\_count](#input\_container\_count) | The number of Semaphore containers to run | `number` | `1` | no |
| <a name="input_db_multi_az"></a> [db\_multi\_az](#input\_db\_multi\_az) | Whether to enable multi-AZ deployment of the database | `bool` | `true` | no |
| <a name="input_db_skip_final_snapshot"></a> [db\_skip\_final\_snapshot](#input\_db\_skip\_final\_snapshot) | Whether to enable multi-AZ deployment of the database | `bool` | `false` | no |
| <a name="input_db_snapshot_identifier"></a> [db\_snapshot\_identifier](#input\_db\_snapshot\_identifier) | The identifier of an existing snapshot to create the database from | `string` | `null` | no |
| <a name="input_ecs_task_architecture"></a> [ecs\_task\_architecture](#input\_ecs\_task\_architecture) | The CPU architecture to run the containers | `string` | `"arm64"` | no |
| <a name="input_ecs_task_cpu"></a> [ecs\_task\_cpu](#input\_ecs\_task\_cpu) | The amount of CPU shares available to containers | `number` | `512` | no |
| <a name="input_ecs_task_memory"></a> [ecs\_task\_memory](#input\_ecs\_task\_memory) | The amount of memory available to containers | `number` | `1024` | no |
| <a name="input_housekeeper_image"></a> [housekeeper\_image](#input\_housekeeper\_image) | The semaphore-housekeeper image | `string` | `"flaudisio/bootcamp-semaphore-housekeeper:0.1.0"` | no |
| <a name="input_housekeeper_schedule"></a> [housekeeper\_schedule](#input\_housekeeper\_schedule) | The semaphore-housekeeper schedule | `string` | `"0 * * * *"` | no |
| <a name="input_logs_retention_in_days"></a> [logs\_retention\_in\_days](#input\_logs\_retention\_in\_days) | The number of days to retain container logs on CloudWatch Logs | `number` | `7` | no |
| <a name="input_semaphore_admin_email"></a> [semaphore\_admin\_email](#input\_semaphore\_admin\_email) | The email of the admin user. Defaults to `<admin-username>@<account-domain>` | `string` | `null` | no |
| <a name="input_semaphore_admin_fullname"></a> [semaphore\_admin\_fullname](#input\_semaphore\_admin\_fullname) | The full name of the admin user | `string` | `"Semaphore Admin"` | no |
| <a name="input_semaphore_admin_username"></a> [semaphore\_admin\_username](#input\_semaphore\_admin\_username) | The username of the admin user | `string` | `"admin"` | no |
| <a name="input_semaphore_extra_env_vars"></a> [semaphore\_extra\_env\_vars](#input\_semaphore\_extra\_env\_vars) | A map of extra environment variables to be configured in the Semaphore container | `map(string)` | `{}` | no |
| <a name="input_semaphore_image"></a> [semaphore\_image](#input\_semaphore\_image) | Docker image to run the Semaphore containers | `string` | `"flaudisio/bootcamp-semaphore:2.8.89-debian"` | no |
| <a name="input_semaphore_max_parallel_tasks"></a> [semaphore\_max\_parallel\_tasks](#input\_semaphore\_max\_parallel\_tasks) | Max allowed parallel tasks if `semaphore_concurrency_mode != ""`. Can also be set/changed within the web UI (project settings) | `number` | `2` | no |
| <a name="input_semaphore_storage_size"></a> [semaphore\_storage\_size](#input\_semaphore\_storage\_size) | The size of the ephemeral storage available to the Semaphore container | `number` | `30` | no |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | The name of the subdomain to be created in the account's Route 53 zone; defaults to the service name | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | The ID of the ECS cluster |
| <a name="output_ecs_service"></a> [ecs\_service](#output\_ecs\_service) | The name of the ECS service |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | The DNS name of the load balancer |
| <a name="output_semaphore_credentials_ssm_parameters"></a> [semaphore\_credentials\_ssm\_parameters](#output\_semaphore\_credentials\_ssm\_parameters) | The SSM parameters that store Semaphore credentials |
| <a name="output_semaphore_endpoint"></a> [semaphore\_endpoint](#output\_semaphore\_endpoint) | The endpoint of the Semaphore server |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
