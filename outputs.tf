output "name" {
  description = "Resource name: <organization>-<environment>-<application>[-<component>], lowercase, [a-z0-9-]. Null when create is false."
  value       = var.create ? local.name : null
}

output "name_prefix" {
  description = "name truncated to 32 characters (trailing hyphen trimmed) for ALB and target group limits. Null when create is false."
  value       = var.create ? local.name_prefix : null
}

output "tags" {
  description = "AWS-style tags with CamelCase keys, ManagedBy = terraform and context.extra_tags merged last. Null when create is false."
  value       = var.create ? local.tags : null
}

output "labels" {
  description = "GCP-style labels with snake_case keys; keys and values lowercased, [^a-z0-9_-] replaced by hyphens, truncated to 63 characters. Null when create is false."
  value       = var.create ? local.labels : null
}
