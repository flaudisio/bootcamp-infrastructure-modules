# WireGuard Server EC2 Instance

## Setting up WireGuard Portal

After deploying the instance, follow the steps below to access WireGuard Portal and to configure the VPN server and clients.

1. Get the WireGuard Portal admin username and password from SSM Parameter Store. Example using AWS CLI:

    ```console
    $ aws ssm get-parameters-by-path --path '/wireguard' --with-decryption --query 'Parameters[].[Name, Value]'
    ```

1. Login to the Portal web GUI. The portal endpoint is exposed by the `vpn_portal_endpoint` output (e.g. https://vpn.example.com).

After logging in, you'll see the following banner:

```plaintext
Warning: WireGuard Interface wg0 is not fully configured! Configurations may be incomplete and non functional!
```

To fix it, follow the steps below:

1. Go to the **Administration** area and open the configuration are of the `wg0` interface.

1. (Required) Set **Public Endpoint for Clients** to the value exposed by the module's `vpn_public_endpoint_for_clients`
   output (e.g. `vpn.example.com:51820`).

1. (Required) Set **MTU** to `0` to avoid the `Key: 'Device.Mtu' Error:Field validation for 'Mtu' failed on the 'lte' tag`
   error.

1. (Optional) Change any other fields you may find useful (e.g. DNS Servers, etc).

1. Click the **Save** button.

1. Done! Now you can create VPN peers as you wish.

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
| <a name="module_ec2_iam_policy"></a> [ec2\_iam\_policy](#module\_ec2\_iam\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | 5.9.2 |
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | terraform-aws-modules/ec2-instance/aws | 4.2.1 |
| <a name="module_ec2_security_group"></a> [ec2\_security\_group](#module\_ec2\_security\_group) | terraform-aws-modules/security-group/aws | 4.16.2 |
| <a name="module_smtp_iam_policy"></a> [smtp\_iam\_policy](#module\_smtp\_iam\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | 5.9.2 |
| <a name="module_smtp_iam_user"></a> [smtp\_iam\_user](#module\_smtp\_iam\_user) | terraform-aws-modules/iam/aws//modules/iam-user | 5.10.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | flaudisio/standard-tags/aws | 0.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_user_policy_attachment.smtp_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route53_record.instance_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.public_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.wg_portal_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.wg_portal_admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.smtp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_route53_zone_id"></a> [account\_route53\_zone\_id](#input\_account\_route53\_zone\_id) | The ID of the account's Route 53 zone | `string` | n/a | yes |
| <a name="input_account_route53_zone_name"></a> [account\_route53\_zone\_name](#input\_account\_route53\_zone\_name) | The name of the account's Route 53 zone | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of the EC2 instance | `string` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The SSH public key material to be configured in the EC2 instance | `string` | n/a | yes |
| <a name="input_public_subnet_id"></a> [public\_subnet\_id](#input\_public\_subnet\_id) | The ID of the public subnet where the instance will be deployed on | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the resources will be deployed on | `string` | n/a | yes |
| <a name="input_allow_ssh_from_cidrs"></a> [allow\_ssh\_from\_cidrs](#input\_allow\_ssh\_from\_cidrs) | A list of CIDRs to be allowed to access the SSH port of the instance | `list(string)` | `[]` | no |
| <a name="input_ami_architecture"></a> [ami\_architecture](#input\_ami\_architecture) | The architecture of the AMI used to deploy the EC2 instances | `string` | `"arm64"` | no |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | The name of the AMI used to deploy the EC2 instances | `string` | `"ubuntu-base-22.04-*"` | no |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | The owner of the AMI used to deploy the EC2 instances | `string` | `"self"` | no |
| <a name="input_wireguard_port"></a> [wireguard\_port](#input\_wireguard\_port) | The port where the WireGuard server will listen to | `number` | `51820` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The ID of the EC2 instance |
| <a name="output_instance_private_dns"></a> [instance\_private\_dns](#output\_instance\_private\_dns) | The private DNS of the EC2 instance |
| <a name="output_instance_private_ip"></a> [instance\_private\_ip](#output\_instance\_private\_ip) | The private IP of the EC2 instance |
| <a name="output_instance_public_dns"></a> [instance\_public\_dns](#output\_instance\_public\_dns) | The public DNS of the EC2 instance |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | The public IP of the EC2 instance |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the instance's security group |
| <a name="output_vpn_portal_credentials_ssm_parameters"></a> [vpn\_portal\_credentials\_ssm\_parameters](#output\_vpn\_portal\_credentials\_ssm\_parameters) | The SSM parameters that store the VPN portal credentials |
| <a name="output_vpn_portal_endpoint"></a> [vpn\_portal\_endpoint](#output\_vpn\_portal\_endpoint) | The WireGuard Portal endpoint for configuring the VPN service and clients |
| <a name="output_vpn_public_endpoint_for_clients"></a> [vpn\_public\_endpoint\_for\_clients](#output\_vpn\_public\_endpoint\_for\_clients) | The VPN public endpoint for clients. Use it for the initial setup of WG Portal |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
