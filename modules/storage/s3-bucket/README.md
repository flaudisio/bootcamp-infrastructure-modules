# S3 Bucket

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
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | 3.7.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | flaudisio/standard-tags/aws | 0.2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The ID of the account | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The team that owns the S3 bucket | `string` | n/a | yes |
| <a name="input_service"></a> [service](#input\_service) | The service related to the S3 bucket | `string` | n/a | yes |
| <a name="input_append_account_id"></a> [append\_account\_id](#input\_append\_account\_id) | Whether to append the account ID to the bucket name | `bool` | `false` | no |
| <a name="input_append_environment"></a> [append\_environment](#input\_append\_environment) | Whether to append the environment name to the bucket name | `bool` | `false` | no |
| <a name="input_append_region"></a> [append\_region](#input\_append\_region) | Whether to append the current AWS region to the bucket name | `bool` | `false` | no |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | The object ownership configuration | `string` | `"BucketOwnerEnforced"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the bucket |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the bucket |
| <a name="output_bucket_region"></a> [bucket\_region](#output\_bucket\_region) | The region of the bucket |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
