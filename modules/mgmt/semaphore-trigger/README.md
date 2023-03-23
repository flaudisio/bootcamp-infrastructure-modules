# Semaphore Trigger

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eventbridge"></a> [eventbridge](#module\_eventbridge) | terraform-aws-modules/eventbridge/aws | 1.17.1 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | terraform-aws-modules/lambda/aws | 4.7.1 |
| <a name="module_lambda_security_group"></a> [lambda\_security\_group](#module\_lambda\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_sqs_queue"></a> [sqs\_queue](#module\_sqs\_queue) | terraform-aws-modules/sqs/aws | 4.0.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | flaudisio/standard-tags/aws | 0.1.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The ID of the account | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnet IDs to deploy the Lambda function to | `list(string)` | n/a | yes |
| <a name="input_semaphore_endpoint"></a> [semaphore\_endpoint](#input\_semaphore\_endpoint) | The endpoint of the Ansible Semaphore server | `string` | n/a | yes |
| <a name="input_semaphore_project_id"></a> [semaphore\_project\_id](#input\_semaphore\_project\_id) | The ID of the Ansible Semaphore project that manages instances | `number` | n/a | yes |
| <a name="input_semaphore_token"></a> [semaphore\_token](#input\_semaphore\_token) | The token of the Ansible Semaphore server | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the Lambda function will be deployed on | `string` | n/a | yes |
| <a name="input_attach_security_groups"></a> [attach\_security\_groups](#input\_attach\_security\_groups) | A list of security groups to be attached to the function | `list(string)` | `[]` | no |
| <a name="input_enable_eventbridge_rules"></a> [enable\_eventbridge\_rules](#input\_enable\_eventbridge\_rules) | Whether to make the EventBridge rules to watch events. Change to `false` to disable the entire Semaphore Trigger workflow | `bool` | `true` | no |
| <a name="input_enable_lambda_function"></a> [enable\_lambda\_function](#input\_enable\_lambda\_function) | Whether to enable the Lambda function. Change to `false` to ignore new instance launches | `bool` | `true` | no |
| <a name="input_function_memory_size"></a> [function\_memory\_size](#input\_function\_memory\_size) | The amount of memory (in MB) available to the function at runtime | `number` | `128` | no |
| <a name="input_function_timeout"></a> [function\_timeout](#input\_function\_timeout) | The amount of time (in seconds) the function has to run | `number` | `60` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventbridge_rule"></a> [eventbridge\_rule](#output\_eventbridge\_rule) | The name of the created EventBridge rule |
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | The ARN of the Lambda Function |
| <a name="output_function_cloudwatch_log_group"></a> [function\_cloudwatch\_log\_group](#output\_function\_cloudwatch\_log\_group) | The name of the function's CloudWatch Log Group |
| <a name="output_function_iam_role"></a> [function\_iam\_role](#output\_function\_iam\_role) | The name of the IAM role created for the Lambda function |
| <a name="output_function_invoke_arn"></a> [function\_invoke\_arn](#output\_function\_invoke\_arn) | The Invoke ARN of the Lambda Function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | The name of the Lambda Function |
| <a name="output_sqs_queue_arn"></a> [sqs\_queue\_arn](#output\_sqs\_queue\_arn) | The ARN of the SQS queue |
| <a name="output_sqs_queue_name"></a> [sqs\_queue\_name](#output\_sqs\_queue\_name) | The name of the SQS queue |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
