# Architecture

## Scope

This repository models a small OCI network foundation. The intent is to demonstrate how a reusable Terraform module can own infrastructure relationships while an environment layer supplies deployment-specific values.

```text
                         OCI Region
                             |
                            VCN
                             |
             +---------------+---------------+
             |                               |
        Public subnet                   Private subnet
             |                               |
       Public route table             Private route table
             |                               |
       Internet Gateway                 NAT Gateway
                                             |
                                      outbound internet

                  VCN ---- Service Gateway ---- OCI services
```

## Resource ownership

| Layer | Owns | Does not own |
|---|---|---|
| Environment | CIDRs, names, compartment/region inputs | Network resource implementation details |
| Network module | VCN, subnets, gateways, route tables | Application configuration |
| CI validation | Formatting and static Terraform validation | Cloud deployment |

## Traffic intent

**Public subnet:** resources that explicitly require an internet-facing path can use the public route table and Internet Gateway.

**Private subnet:** workloads without an inbound internet requirement use the private route table. NAT provides outbound internet access without assigning a public IP to the workload.

**OCI services:** the Service Gateway provides private access to supported OCI services. It is a separate path from general internet egress.

## Why the module boundary matters

The environment should be able to change CIDRs, names, and deployment-specific values without changing the network implementation. Conversely, a change to the module should be reviewable as a potentially broader infrastructure change.

## Production extension points

A production implementation would normally add controls around:

- remote state and locking
- compartment and IAM boundaries
- NSGs/security rules
- tagging and cost attribution
- subnet sizing and IP capacity
- availability-domain/fault-domain placement where applicable
- plan review and approval before apply
- drift detection
- provider upgrade testing

Those concerns are intentionally separated from the small reference network so that the example remains understandable and safe to run.
