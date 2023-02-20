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
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | terraform-aws-modules/ecs/aws | 4.1.3 |
| <a name="module_ecs_task_iam_role"></a> [ecs\_task\_iam\_role](#module\_ecs\_task\_iam\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | 5.11.2 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | flaudisio/standard-tags/aws | 0.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnet IDs to deploy the containers to | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_allow_vpc_access"></a> [allow\_vpc\_access](#input\_allow\_vpc\_access) | Whether to allow any VPC-originating access to private resources. Only enable for debugging purposes! | `bool` | `false` | no |
| <a name="input_container_count"></a> [container\_count](#input\_container\_count) | The number of Prometheus containers to run | `number` | `1` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Docker image to run the Prometheus containers | `string` | `"prom/prometheus:2.37.6"` | no |
| <a name="input_ecs_task_cpu"></a> [ecs\_task\_cpu](#input\_ecs\_task\_cpu) | The ECS task CPU | `number` | `256` | no |
| <a name="input_ecs_task_memory"></a> [ecs\_task\_memory](#input\_ecs\_task\_memory) | The ECS task memory | `number` | `512` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | The ID of the ECS cluster |
| <a name="output_ecs_service"></a> [ecs\_service](#output\_ecs\_service) | The name of the ECS service |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
