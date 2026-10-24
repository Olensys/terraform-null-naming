# terraform-null-naming

Renders a context object into resource names, AWS tags and GCP labels

## Opinions

- Names are lowercased and every character outside `[a-z0-9-]` becomes `-` (underscores included): `<organization>-<environment>-<application>[-<component>]`.
- `name_prefix` is `name` cut to 32 characters with any trailing `-` removed, to fit ALB and target group name limits.
- `tags` use CamelCase keys (AWS style): `Organization`, `Environment`, `Application`, `Component` (only when set), `Owner`, `CostCenter`, then `extra_tags` merged last.
- `ManagedBy = "terraform"` is always present in `tags` (and `managed_by` in `labels`).
- `labels` use snake_case keys (GCP style). Keys and values are lowercased, every character outside `[a-z0-9_-]` becomes `-`, and each is truncated to 63 characters. `extra_tags` keys are normalised the same way.
- `context.environment` must be one of `dev`, `staging`, `prod`, `test`, `shared`.
- No provider and no resources. With `create = false` every output is `null`.

## Usage

```hcl
module "naming" {
  source = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.0"

  context = {
    organization = "olensys"
    environment  = "dev"
    application  = "example"
    component    = "web"
    owner        = "platform"
    cost_center  = "eng"
  }
}

# module.naming.name, .name_prefix, .tags, .labels
```

## Use with library modules

Render the naming module once and pass its outputs to library modules. `labels` are already GCP-safe (lowercase, `[a-z0-9_-]`, at most 63 characters), so they can be passed to Google modules unchanged.

```hcl
module "naming" {
  source  = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.0"
  context = var.context
}

module "bucket" {
  source  = "git::https://github.com/Olensys/terraform-aws-s3-bucket.git?ref=v1.1.0"
  name    = "assets"
  context = var.context
  tags    = module.naming.tags # Google modules: labels = module.naming.labels
}
```

Caller `tags`/`labels` win over `context.extra_tags`, which every module applies as a shared baseline.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Deployment context used for naming, tagging and environment-dependent defaults. | <pre>object({<br/>    organization = string<br/>    environment  = string<br/>    application  = string<br/>    component    = optional(string)<br/>    owner        = string<br/>    cost_center  = string<br/>    extra_tags   = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to render outputs. Set false and every output is null. | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_labels"></a> [labels](#output\_labels) | GCP-style labels with snake\_case keys; keys and values lowercased, [^a-z0-9\_-] replaced by hyphens, truncated to 63 characters. Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Resource name: <organization>-<environment>-<application>[-<component>], lowercase, [a-z0-9-]. Null when create is false. |
| <a name="output_name_prefix"></a> [name\_prefix](#output\_name\_prefix) | name truncated to 32 characters (trailing hyphen trimmed) for ALB and target group limits. Null when create is false. |
| <a name="output_tags"></a> [tags](#output\_tags) | AWS-style tags with CamelCase keys, ManagedBy = terraform and context.extra\_tags merged last. Null when create is false. |
<!-- END_TF_DOCS -->
