# Changelog

## 1.0.1

### Fixes

- render declared provider constraints and skip .terraform in trivy scans
- declare required_version and providers in examples/minimal

## 1.0.0

- Renders a `context` object into `name`, `name_prefix`, AWS-style `tags` and GCP-style `labels`.
- Validates `context.environment`; `create = false` nulls every output.
