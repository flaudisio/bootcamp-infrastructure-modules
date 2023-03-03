# Changelog

## Unreleased

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
