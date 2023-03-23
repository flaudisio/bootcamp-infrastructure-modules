# Security Groups for Infrastructure Services

This module deploys security groups to be allowed in infrastructure components so region-level services like Ansible
Semaphore and Prometheus can work.

## Available security groups

| Terraform output | Goal | How to use in modules |
|------------------|------|-----------------------|
| `semaphore_server_security_group` | Ansible Semaphore server base security group | Attach to Semaphore server instances |
| `prometheus_server_security_group`| Prometheus server base security group | Attach to Prometheus server instances |
| `infra_services_security_group`| Infra services access | Attach to client instances to allow access from Semaphore, Prometheus, etc |

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
| <a name="module_infra_services_security_group"></a> [infra\_services\_security\_group](#module\_infra\_services\_security\_group) | terraform-aws-modules/security-group/aws | 4.17.1 |
| <a name="module_prometheus_server_security_group"></a> [prometheus\_server\_security\_group](#module\_prometheus\_server\_security\_group) | terraform-aws-modules/security-group/aws | 4.17.1 |
| <a name="module_semaphore_server_security_group"></a> [semaphore\_server\_security\_group](#module\_semaphore\_server\_security\_group) | terraform-aws-modules/security-group/aws | 4.17.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | flaudisio/standard-tags/aws | 0.2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the resources will be deployed on | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_infra_services_security_group"></a> [infra\_services\_security\_group](#output\_infra\_services\_security\_group) | The ID of the security group to be attached to instances to allow access from infrastructure services |
| <a name="output_prometheus_server_security_group"></a> [prometheus\_server\_security\_group](#output\_prometheus\_server\_security\_group) | The ID of the security group to be attached to Prometheus server |
| <a name="output_semaphore_server_security_group"></a> [semaphore\_server\_security\_group](#output\_semaphore\_server\_security\_group) | The ID of the security group to be attached to Ansible Semaphore server |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
