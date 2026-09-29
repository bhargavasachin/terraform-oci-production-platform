# Configuration patterns

Terraform projects get harder to maintain when environment values, realm differences, and reusable infrastructure logic are mixed together. This note shows a small pattern for keeping those concerns separate.

## Layering

A useful model is:

```text
base configuration
      +
environment values
      +
optional realm/region override
      |
      v
resolved configuration
      |
      v
module inputs
```

The module should consume the resolved values. It should not need to know why a value changed between environments.

## Example

A configuration file can describe the common shape:

```json
{
  "network": {
    "cidr": "10.20.0.0/16",
    "public_subnet_cidr": "10.20.1.0/24",
    "private_subnet_cidr": "10.20.2.0/24"
  }
}
```

An environment or realm-specific layer can then override only what differs:

```json
{
  "network": {
    "private_subnet_cidr": "10.30.2.0/24"
  }
}
```

Terraform can decode the files and merge the maps before passing the final object to a module. The important part is that the precedence is explicit and documented.

## Practical Terraform pattern

```hcl
locals {
  base_config = jsondecode(file("${path.module}/config/base.json"))
  override    = jsondecode(file("${path.module}/config/${var.environment}.json"))

  network = merge(
    local.base_config.network,
    try(local.override.network, {})
  )
}
```

For nested structures, `merge` is shallow. If deeper objects need independent overrides, resolve those layers deliberately rather than assuming `merge` performs a deep merge.

## Why this matters

This approach makes it easier to add another environment without changing the module itself. It also keeps the module interface stable when a region or realm has a different value.

When using `for_each`, prefer stable keys that come from configuration rather than resource attributes that are unknown until apply. Otherwise Terraform can fail during planning because it cannot determine the instance keys ahead of time.

The examples here are intentionally small. In a larger platform, the same idea can be applied to service limits, policy inputs, regional exceptions, and other configuration that legitimately varies by deployment boundary.
