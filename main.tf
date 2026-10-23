locals {
  ctx = var.context

  # Names: lowercase, [a-z0-9-] only.
  name        = replace(lower(join("-", compact([local.ctx.organization, local.ctx.environment, local.ctx.application, local.ctx.component]))), "/[^a-z0-9-]/", "-")
  name_prefix = replace(substr(local.name, 0, 32), "/-+$/", "")

  # Tags: CamelCase keys, extra_tags merged last.
  tags = merge(
    {
      Organization = local.ctx.organization
      Environment  = local.ctx.environment
      Application  = local.ctx.application
    },
    local.ctx.component == null || local.ctx.component == "" ? {} : { Component = local.ctx.component },
    {
      Owner      = local.ctx.owner
      CostCenter = local.ctx.cost_center
      ManagedBy  = "terraform"
    },
    local.ctx.extra_tags,
  )

  # Labels: snake_case keys, lowercase, [a-z0-9_-] only, at most 63 characters.
  label_source = merge(
    {
      organization = local.ctx.organization
      environment  = local.ctx.environment
      application  = local.ctx.application
    },
    local.ctx.component == null || local.ctx.component == "" ? {} : { component = local.ctx.component },
    {
      owner       = local.ctx.owner
      cost_center = local.ctx.cost_center
      managed_by  = "terraform"
    },
    local.ctx.extra_tags,
  )
  labels = {
    for k, v in local.label_source :
    substr(replace(lower(k), "/[^a-z0-9_-]/", "-"), 0, 63) => substr(replace(lower(v), "/[^a-z0-9_-]/", "-"), 0, 63)
  }
}
