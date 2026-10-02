# Terraform OCI Production Platform

Terraform patterns for building a repeatable OCI foundation with clear environment boundaries and reusable modules.

This repository focuses on the parts of OCI infrastructure that tend to become difficult to maintain as environments grow: network layout, naming, input validation, module boundaries, and keeping environment-specific values out of reusable code.

> **Portfolio note:** This is a public reference implementation based on infrastructure patterns used in cloud/platform engineering work. It does not contain company-specific configuration, internal names, credentials, or proprietary implementation details.

## What is here

- Reusable VCN and subnet module
- Separate public and private subnets
- Internet, NAT, and service gateways
- Environment-specific inputs under `environments/`
- Provider and Terraform version constraints per environment
- Formatting and validation workflow
- Examples of keeping reusable modules independent from environment values

## Layout

```text
.
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── versions.tf
│   │   ├── terraform.tfvars.example
│   │   └── outputs.tf
│   └── staging/
│       ├── main.tf
│       ├── variables.tf
│       ├── versions.tf
│       ├── terraform.tfvars.example
│       └── outputs.tf
├── modules/
│   └── network/
│       ├── main.tf
│       ├── variables.tf
│       ├── versions.tf
│       └── outputs.tf
├── docs/
│   ├── architecture.md
│   ├── configuration-patterns.md
│   └── design-decisions.md
├── examples/
│   ├── config-driven/
│   └── configuration/
├── .github/workflows/
│   └── terraform.yml
├── .gitignore
├── LICENSE
└── README.md
```

## Design choices

### Module boundary

The network module owns resources that change together: VCN, gateways, route tables, and subnet definitions. The environment layer owns CIDRs, names, and tenancy-specific inputs.

### Public vs private workloads

Public subnets are intended for resources that explicitly need an internet-facing path. Private subnets use a NAT gateway for outbound internet access and a service gateway for OCI service traffic.

### Inputs instead of hardcoded values

CIDRs, display names, and availability-domain choices are passed into the environment. The module does not assume a particular tenancy, compartment, region, or naming convention.

## Getting started

1. Install Terraform 1.6+.
2. Configure OCI authentication using the OCI provider's supported authentication method.
3. Copy `environments/dev/terraform.tfvars.example` to `terraform.tfvars`.
4. Set the compartment OCID, region, and network CIDRs.
5. Run:

```bash
cd environments/dev
terraform init
terraform fmt -check -recursive ../..
terraform validate
terraform plan
```

Apply only after reviewing the plan:

```bash
terraform apply
```

## Operational considerations

Before applying changes in a shared environment, review state and locking, provider upgrades, subnet CIDR changes, route-table changes, security rule changes, module blast radius, and the recovery path.

For production, state should be stored in a remote backend with appropriate access controls rather than committed to the repository.

## Validation

The GitHub Actions workflow runs formatting and Terraform validation for changes to Terraform files. Cloud credentials are intentionally not required for the validation job.
