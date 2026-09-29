# Configuration-driven Terraform pattern

For larger platforms, keeping a growing list of environment-specific values directly in Terraform becomes difficult to review. A useful pattern is to keep structured, non-secret configuration in JSON and transform it into Terraform maps before resources are created.

The important boundary is that JSON is **configuration**, not a secret store. Credentials and sensitive values should remain in the runtime environment or a secret manager.

A typical shape is:

```json
{
  "dev": {
    "region": "example-region",
    "network": {
      "vcn_cidr": "10.10.0.0/16",
      "public_subnet_cidr": "10.10.1.0/24",
      "private_subnet_cidr": "10.10.2.0/24"
    }
  }
}
```

The Terraform layer can then use `jsondecode(file(...))`, `try()`, `merge()`, and `for_each` to normalize defaults and environment overrides. Keep the transformation step readable; when a local becomes difficult to explain, split the transformation into smaller locals instead of hiding it in a resource expression.

This directory is intentionally documentation-only. It does not require an OCI tenancy to understand the pattern.
