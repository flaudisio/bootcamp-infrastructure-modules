# Consul Cluster

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.4 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | 4.3.1 |
| <a name="module_asg"></a> [asg](#module\_asg) | terraform-aws-modules/autoscaling/aws | 6.7.1 |
| <a name="module_asg_iam_policy"></a> [asg\_iam\_policy](#module\_asg\_iam\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | 5.9.2 |
| <a name="module_asg_security_group"></a> [asg\_security\_group](#module\_asg\_security\_group) | terraform-aws-modules/security-group/aws | 4.17.1 |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | terraform-aws-modules/alb/aws | 8.6.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | flaudisio/standard-tags/aws | 0.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route53_record.load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.cluster_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.gossip_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_ami.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_default_tags.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.asg_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | The name of the account | `string` | n/a | yes |
| <a name="input_account_route53_zone_id"></a> [account\_route53\_zone\_id](#input\_account\_route53\_zone\_id) | The ID of the account's Route 53 zone | `string` | n/a | yes |
| <a name="input_account_route53_zone_name"></a> [account\_route53\_zone\_name](#input\_account\_route53\_zone\_name) | The name of the account's Route 53 zone | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Nomad cluster | `string` | n/a | yes |
| <a name="input_cluster_public_key"></a> [cluster\_public\_key](#input\_cluster\_public\_key) | The SSH public key material to be configured in all EC2 instances of the cluster | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of the server instances | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The team that owns this WordPress site | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnet IDs to deploy the instances to | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_allow_vpc_access"></a> [allow\_vpc\_access](#input\_allow\_vpc\_access) | Whether to allow any VPC-originating access to private resources. Only enable for debugging purposes! | `bool` | `false` | no |
| <a name="input_ami_architecture"></a> [ami\_architecture](#input\_ami\_architecture) | The architecture of the AMI used to deploy the server instances | `string` | `"x86_64"` | no |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | The name of the AMI used to deploy the server instances | `string` | `"ubuntu-base-22.04-*"` | no |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | The owner of the AMI used to deploy the server instances | `string` | `"self"` | no |
| <a name="input_attach_security_groups"></a> [attach\_security\_groups](#input\_attach\_security\_groups) | A list of security groups to be attached to the instances | `list(string)` | `[]` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | The number of server instances | `number` | `3` | no |
| <a name="input_instance_volume_size"></a> [instance\_volume\_size](#input\_instance\_volume\_size) | The size of the root EBS volume attached to server instances | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_consul_endpoint"></a> [consul\_endpoint](#output\_consul\_endpoint) | The endpoint of the Consul cluster |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | The name of the cluster load balancer |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
