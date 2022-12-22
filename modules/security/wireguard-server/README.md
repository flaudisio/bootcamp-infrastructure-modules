# WireGuard Server

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
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | terraform-aws-modules/ec2-instance/aws | 4.2.1 |
| <a name="module_iam_policy"></a> [iam\_policy](#module\_iam\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | 5.9.2 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route53_record.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.vpn_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.vpn_public_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_route53_zone_id"></a> [account\_route53\_zone\_id](#input\_account\_route53\_zone\_id) | The ID of the account's Route 53 zone | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of the EC2 instance | `string` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The SSH public key material to be configured in the EC2 instance | `string` | n/a | yes |
| <a name="input_public_subnet_id"></a> [public\_subnet\_id](#input\_public\_subnet\_id) | The ID of the public subnet where the instance will be deployed on | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_allow_ssh_from_cidrs"></a> [allow\_ssh\_from\_cidrs](#input\_allow\_ssh\_from\_cidrs) | A list of CIDRs to be allowed to access the SSH port of the instance | `list(string)` | `[]` | no |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | The name of the AMI to be used for the instance | `string` | `"ubuntu/images/*ubuntu-jammy-22.04-*-server-20221206"` | no |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | The owner of the AMI to be used for the instance | `string` | `"099720109477"` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | The name of the EC2 instance | `string` | `"wireguard-01"` | no |
| <a name="input_wireguard_address"></a> [wireguard\_address](#input\_wireguard\_address) | The CIDR of the WireGuard server in the VPN tunnel | `string` | `null` | no |
| <a name="input_wireguard_peers"></a> [wireguard\_peers](#input\_wireguard\_peers) | A list of WireGuard peers to be configured in the server | <pre>list(object(<br>    {<br>      name   = string<br>      pubkey = string<br>      ip     = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_wireguard_port"></a> [wireguard\_port](#input\_wireguard\_port) | The port where the WireGuard server will listen to | `number` | `51820` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The ID of the EC2 instance |
| <a name="output_instance_public_dns"></a> [instance\_public\_dns](#output\_instance\_public\_dns) | The public DNS of the EC2 instance |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | The public IP of the EC2 instance |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the instance's security group |
| <a name="output_vpn_endpoint"></a> [vpn\_endpoint](#output\_vpn\_endpoint) | The VPN endpoint to be configured in the client's `wg0.conf` file |
| <a name="output_vpn_public_key_ssm_parameter"></a> [vpn\_public\_key\_ssm\_parameter](#output\_vpn\_public\_key\_ssm\_parameter) | The name of the SSM parameter that stores the VPN public key |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
