module "this" {
  source = "../../"

  context = {
    organization = "olensys"
    environment  = "dev"
    application  = "example"
    component    = "web"
    owner        = "platform"
    cost_center  = "eng"
    extra_tags   = { Team = "Platform" }
  }
}

output "name" {
  description = "Rendered resource name."
  value       = module.this.name
}

output "name_prefix" {
  description = "Rendered name truncated to 32 characters."
  value       = module.this.name_prefix
}

output "tags" {
  description = "Rendered AWS tags."
  value       = module.this.tags
}

output "labels" {
  description = "Rendered GCP labels."
  value       = module.this.labels
}
