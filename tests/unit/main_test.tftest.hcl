# Unit Tests for tf-molecule-wafv2-regional-aws
#
# These tests use a mock AWS provider — no real AWS calls are made.
# Run with:      terraform test -test-directory=tests/unit
# Run verbose:   terraform test -test-directory=tests/unit -verbose
#
# Asserts target plan-KNOWN values only (tf-label id string, resource
# count, and input pass-throughs). Computed attributes such as the Web
# ACL arn/id are unknown under a mock provider, so they are not asserted.

mock_provider "aws" {}

variables {
  namespace    = "eg"
  stage        = "test"
  name         = "thing"
  resource_arn = "arn:aws:apigateway:us-east-1::/restapis/abc123/stages/prod"
}

# ---------------------------------------------------------------------------
# Test: module creates the Web ACL + association when enabled (default)
# ---------------------------------------------------------------------------
run "creates_when_enabled" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl.this[0].name == "eg-test-thing"
    error_message = "Web ACL name should equal the tf-label id 'eg-test-thing'"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this) == 1
    error_message = "Exactly one Web ACL should be planned when enabled"
  }

  assert {
    condition     = aws_wafv2_web_acl_association.this[0].resource_arn == var.resource_arn
    error_message = "Association resource_arn should pass through the input resource_arn"
  }
}

# ---------------------------------------------------------------------------
# Test: managed rules and rate limit are wired onto the Web ACL
# ---------------------------------------------------------------------------
run "wires_rules_when_enabled" {
  command = plan

  assert {
    condition     = aws_wafv2_web_acl.this[0].scope == "REGIONAL"
    error_message = "Web ACL scope should be REGIONAL"
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this[0].rule) == length(var.managed_rules) + 1
    error_message = "Web ACL should have one rule per managed rule group plus the rate-limit rule"
  }
}

# ---------------------------------------------------------------------------
# Test: nothing is created when the module is disabled
# ---------------------------------------------------------------------------
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this) == 0
    error_message = "No Web ACL should be planned when enabled = false"
  }

  assert {
    condition     = length(aws_wafv2_web_acl_association.this) == 0
    error_message = "No Web ACL association should be planned when enabled = false"
  }

  assert {
    condition     = output.web_acl_arn == ""
    error_message = "web_acl_arn output should be empty when disabled"
  }
}
