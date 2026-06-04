# Molecule: WAFv2 Web ACL (REGIONAL scope) with API Gateway Association

module "web_acl" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-wafv2-web-acl-aws.git?ref=918046583c7de2e902385e21abd6cffabb070b07"

  context       = module.this.context
  name          = var.name
  scope         = "REGIONAL"
  managed_rules = var.managed_rules
  rate_limit    = var.rate_limit
}

module "association" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-wafv2-web-acl-association-aws.git?ref=b5cb29249dc3f6fa02b3ba0ac03f4b05b49ed8d0"

  context      = module.this.context
  web_acl_arn  = module.web_acl.arn
  resource_arn = var.resource_arn

  depends_on = [module.web_acl]
}
