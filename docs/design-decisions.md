# Design decisions

This document captures decisions that are useful when this pattern is carried into a larger OCI environment.

## Keep environment values outside modules

The reusable module accepts IDs, CIDRs, names and tags as inputs. Environment directories own those values. This keeps the module usable across accounts/compartments without editing module code.

## Prefer explicit network paths

Public and private subnets use separate route tables. Private workloads get outbound access through NAT and OCI service access through the service gateway. A workload does not become public simply because the VCN has an internet gateway.

## Treat provider upgrades as infrastructure changes

Terraform provider upgrades can change planning behavior, resource schemas and replacement semantics. Pin the provider range and review the plan before widening or changing it.

## Keep credentials out of the repository

Examples use placeholders. Authentication is supplied by the operator or CI environment. State should use a protected remote backend in a real shared environment.

## Validate before plan/apply

Formatting and validation are intentionally separate from cloud credentials. A pull request should catch syntax and configuration problems before a plan is run with access to an OCI tenancy.
