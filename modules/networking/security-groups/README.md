# Security groups

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_prometheus_scrape_security_group"></a> [prometheus\_scrape\_security\_group](#module\_prometheus\_scrape\_security\_group) | terraform-aws-modules/security-group/aws | 4.17.1 |
| <a name="module_prometheus_server_security_group"></a> [prometheus\_server\_security\_group](#module\_prometheus\_server\_security\_group) | terraform-aws-modules/security-group/aws | 4.17.1 |
| <a name="module_semaphore_access_security_group"></a> [semaphore\_access\_security\_group](#module\_semaphore\_access\_security\_group) | terraform-aws-modules/security-group/aws | 4.17.1 |
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
| <a name="output_prometheus_scrape_security_group"></a> [prometheus\_scrape\_security\_group](#output\_prometheus\_scrape\_security\_group) | The ID of the security group to be attached to instances to enable scraping from Prometheus server |
| <a name="output_prometheus_server_security_group"></a> [prometheus\_server\_security\_group](#output\_prometheus\_server\_security\_group) | The ID of the security group to be attached to Prometheus server |
| <a name="output_semaphore_access_security_group"></a> [semaphore\_access\_security\_group](#output\_semaphore\_access\_security\_group) | The ID of the security group to be attached to instances to enable access from Ansible Semaphore server |
| <a name="output_semaphore_server_security_group"></a> [semaphore\_server\_security\_group](#output\_semaphore\_server\_security\_group) | The ID of the security group to be attached to Ansible Semaphore server |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
