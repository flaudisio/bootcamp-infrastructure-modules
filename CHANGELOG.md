# Changelog

## Unreleased

## v0.7.0 - 2023-03-31

### Updates

- `services/nomad-cluster`
  - Add `-ec2` suffix to IAM resources.

- Misc
  - Terraform has been downgraded to v1.3.9.

## v0.6.3 - 2023-03-31

### Updates

- `services/nomad-cluster`
  - Update ASG IAM policy for accessing the Consul gossip key.

- `mgmt/semaphore-ec2`, `mgmt/semaphore-ecs`
  - Update permissions for accessing SSM parameters.

## v0.6.2 - 2023-03-31

### Updates

- `services/nomad-cluster`
  - Fix `server_instance_count` input validation.

## v0.6.1 - 2023-03-29

### Updates

- `services/nomad-cluster`
  - The number of server instances can now be between 1 and 7.

## v0.6.0 - 2023-03-29

### New modules

- `services/consul-cluster`

### Updates

- All modules
  - The `standard-tags` module has been bumped to v0.3.0, which means the `service` tag has been renamed to `service-name`.
- `services/nomad-cluster`
  - The `cluster_name` input is now used as identifier for all resources.
- `networking/wireguard-server`
  - Update WG Portal base path on Parameter Store to `/wireguard/wg-portal`.
- `networking/security-groups`
  - Allow Consul client communication on `infra-services-access` security group.

- Misc
  - Terraform has been updated to v1.4.2.
  - TFLint hook has been added to pre-commit configuration.

## v0.5.0 - 2023-03-23

### New modules

- `mgmt/semaphore-ecs`
- `services/nomad-cluster`

### Affected modules

- `mgmt/semaphore-server`
- `mgmt/semaphore-trigger`
- `networking/wireguard-server`
- `services/wordpress-site`

### Description

- The `services/nomad-cluster` module has been introduced to deploy Nomad clusters composed by an ASG for servers and 0 or many
  ASGs for clients.
- The `mgmt/semaphore-ecs` module has been introduced to deploy Ansible Semaphore on ECS/Fargate.
- The `mgmt/semaphore-server` module has been renamed to `mgmt/semaphore-ec2`.
- All supported modules now use `gp3` as default EBS storage type.
- Minor fixes on resource tagging and explicit dependencies.

### Related links

- flaudisio/bootcamp-infrastructure-modules#21
- flaudisio/bootcamp-infrastructure-modules#20
- flaudisio/bootcamp-infrastructure-modules#19

## v0.4.0 - 2023-03-03

### New modules

- `mgmt/prometheus-server`
- `networking/security-groups`
- `storage/s3-bucket`

### Affected modules

- `mgmt/semaphore-server`
- `mgmt/semaphore-trigger`
- `networking/vpc`
- `networking/wireguard-server`
- `services/wordpress-site`

### Description

- The `ubuntu-base-22.04-*` AMI is now the default for all supported modules.
- Default VPC resources are now managed by the `networking/vpc` module.
- The Semaphore server stack has been changed to use ALB+ACM, RDS (Postgres) and auto scaling group.

### Related links

- flaudisio/bootcamp-infrastructure-modules#18
- flaudisio/bootcamp-infrastructure-modules#17
- flaudisio/bootcamp-infrastructure-modules#16
- flaudisio/bootcamp-infrastructure-modules#15
- flaudisio/bootcamp-infrastructure-modules#14
- flaudisio/bootcamp-infrastructure-modules#13
- flaudisio/bootcamp-infrastructure-modules#12
- flaudisio/bootcamp-infrastructure-modules#11
- flaudisio/bootcamp-infrastructure-modules#10
- flaudisio/bootcamp-infrastructure-modules#9
- flaudisio/bootcamp-infrastructure-modules#8

## v0.3.0 - 2023-02-16

### Affected modules

- `mgmt/semaphore-server`
- `mgmt/semaphore-trigger`
- `networking/route53-zone`
- `networking/vpc`
- `networking/wireguard-server`
- `services/wordpress-site`

### Description

- Standard tags are now required for all supported resources.
- The Lambda function handler in `semaphore-trigger` has been changed to `app.handler`.
- The `wordpress-site` module has been changed to use an EFS filesystem instead of the S3 bucket, as well the application
  port and health check path.

### Related links

- flaudisio/bootcamp-infrastructure-modules#7
- flaudisio/bootcamp-infrastructure-modules#6
- flaudisio/bootcamp-infrastructure-modules#5

## v0.2.0 - 2023-01-15

### New modules

- `mgmt/semaphore-server`
- `mgmt/semaphore-trigger`
- `services/wordpress-site`

### Affected modules

- `account/account-baseline`
- `networking/vpc`
- `security/wireguard-server`

### Description

- The `security/wireguard-server` module has been renamed to `networking/wireguard-server`.
- The `networking/vpc` module now has tags for all deployed resources.
- The `account/account-baseline` module now enables the account-level S3 public access block feature.

### Related links

- flaudisio/bootcamp-infrastructure-modules#4

## v0.1.0 - 2023-01-08

### New modules

- `account/region-baseline`

### Affected modules

- `account/baseline`
- `networking/vpc`
- `security/wireguard-server`

### Description

- The `account/baseline` module has been renamed to `account/account-baseline`.
- The `networking/vpc` module now creates and exposes subnet groups for RDS and ElastiCache.
- The `security/wireguard-server` module now deploys an IAM user and SSM parameters for using SMTP credentials in the
  WireGuard Portal configuration.

### Related links

- flaudisio/bootcamp-infrastructure-modules#3

## v0.0.2 - 2023-01-02

### Affected modules

- `networking/vpc`

### Description

- The lists of database and ElastiCache subnets were added to the outputs of the VPC module.

### Related links

- flaudisio/bootcamp-infrastructure-modules#2

## v0.0.1 - 2023-01-02

### New modules

- `account/baseline`
- `networking/route53-zone`
- `networking/vpc`
- `security/wireguard-server`

### Description

- Initial modules for creating the baseline of an AWS account.

### Related links

- flaudisio/bootcamp-infrastructure-modules#1
