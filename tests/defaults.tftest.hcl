variables {
  context = {
    organization = "olensys"
    environment  = "prod"
    application  = "ct-api"
    component    = "web"
    owner        = "platform"
    cost_center  = "eng"
  }
}

run "test_name_composition" {
  command = plan

  assert {
    condition     = output.name == "olensys-prod-ct-api-web"
    error_message = "name must be organization-environment-application-component."
  }

  assert {
    condition     = output.name_prefix == "olensys-prod-ct-api-web"
    error_message = "name_prefix must equal name when name is at most 32 characters."
  }
}

run "test_name_without_component" {
  command = plan

  variables {
    context = {
      organization = "olensys"
      environment  = "prod"
      application  = "ct-api"
      owner        = "platform"
      cost_center  = "eng"
    }
  }

  assert {
    condition     = output.name == "olensys-prod-ct-api"
    error_message = "name must omit the component when it is not set."
  }

  assert {
    condition     = !contains(keys(output.tags), "Component") && !contains(keys(output.labels), "component")
    error_message = "Component tag and label must be absent when component is not set."
  }
}

run "test_tags_keys" {
  command = plan

  variables {
    context = {
      organization = "olensys"
      environment  = "prod"
      application  = "ct-api"
      component    = "web"
      owner        = "platform"
      cost_center  = "eng"
      extra_tags   = { Team = "Platform" }
    }
  }

  assert {
    condition = alltrue([
      for k in ["Organization", "Environment", "Application", "Component", "Owner", "CostCenter", "ManagedBy", "Team"] :
      contains(keys(output.tags), k)
    ])
    error_message = "tags must contain the CamelCase context keys and extra_tags."
  }

  assert {
    condition     = output.tags.ManagedBy == "terraform"
    error_message = "ManagedBy must be terraform."
  }
}

run "test_labels_are_normalised" {
  command = plan

  variables {
    context = {
      organization = "olensys"
      environment  = "prod"
      application  = "ct-api"
      owner        = "Platform Team"
      cost_center  = "R&D.Core"
      extra_tags   = { "Cost Team" = "Big Data!" }
    }
  }

  assert {
    condition     = output.labels.owner == "platform-team"
    error_message = "owner label must be normalised."
  }

  assert {
    condition     = output.labels.cost_center == "r-d-core"
    error_message = "cost_center label must be normalised."
  }

  assert {
    condition     = output.labels["cost-team"] == "big-data-"
    error_message = "extra_tags keys and values must be normalised in labels."
  }

  assert {
    condition = alltrue(concat(
      [for k in keys(output.labels) : can(regex("^[a-z0-9_-]{1,63}$", k))],
      [for v in values(output.labels) : can(regex("^[a-z0-9_-]{1,63}$", v))]
    ))
    error_message = "Every label key and value must match ^[a-z0-9_-]{1,63}$."
  }
}

run "test_long_name_prefix_is_trimmed" {
  command = plan

  variables {
    context = {
      organization = "olensys"
      environment  = "prod"
      application  = "ct-api-gateway-service"
      owner        = "platform"
      cost_center  = "eng"
    }
  }

  assert {
    condition     = length(output.name_prefix) <= 32 && !endswith(output.name_prefix, "-")
    error_message = "name_prefix must be at most 32 characters with no trailing hyphen."
  }
}

run "test_invalid_environment_rejected" {
  command = plan

  variables {
    context = {
      organization = "olensys"
      environment  = "production"
      application  = "ct-api"
      owner        = "platform"
      cost_center  = "eng"
    }
  }

  expect_failures = [var.context]
}

run "test_create_false_outputs_null" {
  command = plan

  variables {
    create = false
  }

  assert {
    condition     = output.name == null && output.name_prefix == null && output.tags == null && output.labels == null
    error_message = "All outputs must be null when create is false."
  }
}
