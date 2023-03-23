# Nomad Cluster

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
| <a name="module_client_instances"></a> [client\_instances](#module\_client\_instances) | ./modules/instances | n/a |
| <a name="module_intra_security_group"></a> [intra\_security\_group](#module\_intra\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_server_instances"></a> [server\_instances](#module\_server\_instances) | ./modules/instances | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | flaudisio/standard-tags/aws | 0.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Nomad cluster | `string` | n/a | yes |
| <a name="input_cluster_public_key"></a> [cluster\_public\_key](#input\_cluster\_public\_key) | The SSH public key material to be configured in all EC2 instances of the cluster | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The team that owns this WordPress site | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnet IDs to deploy the instances to | `list(string)` | n/a | yes |
| <a name="input_server_instance_type"></a> [server\_instance\_type](#input\_server\_instance\_type) | The type of the server instances | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_allow_vpc_access"></a> [allow\_vpc\_access](#input\_allow\_vpc\_access) | Whether to allow any VPC-originating access to private resources. Only enable for debugging purposes! | `bool` | `false` | no |
| <a name="input_attach_security_groups"></a> [attach\_security\_groups](#input\_attach\_security\_groups) | A list of security groups to be attached to the instances | `list(string)` | `[]` | no |
| <a name="input_client_instance_groups"></a> [client\_instance\_groups](#input\_client\_instance\_groups) | A map of objects describing the client instance groups to be created | <pre>map(object(<br>    {<br>      ami_name         = optional(string, "ubuntu-base-22.04-*")<br>      ami_owner        = optional(string, "self")<br>      architecture     = optional(string, "x86_64")<br>      instance_type    = string<br>      instance_count   = number<br>      root_volume_size = optional(number, 30)<br>    }<br>  ))</pre> | `{}` | no |
| <a name="input_server_ami_architecture"></a> [server\_ami\_architecture](#input\_server\_ami\_architecture) | The architecture of the AMI used to deploy the server instances | `string` | `"x86_64"` | no |
| <a name="input_server_ami_name"></a> [server\_ami\_name](#input\_server\_ami\_name) | The name of the AMI used to deploy the server instances | `string` | `"ubuntu-base-22.04-*"` | no |
| <a name="input_server_ami_owner"></a> [server\_ami\_owner](#input\_server\_ami\_owner) | The owner of the AMI used to deploy the server instances | `string` | `"self"` | no |
| <a name="input_server_instance_count"></a> [server\_instance\_count](#input\_server\_instance\_count) | The number of server instances | `number` | `3` | no |
| <a name="input_server_root_volume_size"></a> [server\_root\_volume\_size](#input\_server\_root\_volume\_size) | The size of the root EBS volume attached to server instances | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_asg_names"></a> [client\_asg\_names](#output\_client\_asg\_names) | The names of the clients' auto scaling groups |
| <a name="output_cluster_intra_security_group"></a> [cluster\_intra\_security\_group](#output\_cluster\_intra\_security\_group) | The name of the cluster intra security group |
| <a name="output_server_asg_name"></a> [server\_asg\_name](#output\_server\_asg\_name) | The name of the server auto scaling group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
