# Changelog

## Unreleased

## v0.1.0 - 2023-01-08

### New modules

- `account/region-baseline`

### Modules affected

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

### Modules affected

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
