output "web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL"
  value       = module.web_acl.arn
}

output "web_acl_id" {
  description = "ID of the WAFv2 Web ACL"
  value       = module.web_acl.id
}
