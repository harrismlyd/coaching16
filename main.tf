
# 🚀 Step 1: Fetch the Primary Domain's Hosted Zone
data "aws_route53_zone" "primary" {
  name         = "sctp-sandbox.com"  # Replace with your actual domain if different
  private_zone = false
}

# Create an ACM Certificate for API Gateway
resource "aws_acm_certificate" "api_cert" {
  domain_name       = "coach16-urlshortener.sctp-sandbox.com"  # Replace with your custom domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Create the DNS Validation Record in Route 53
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# 🚀 Validate the ACM Certificate
resource "aws_acm_certificate_validation" "api_cert_validation" {
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# 🚀 Create an API Gateway (HTTP API or REST API)
resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "Coach16URLShortener"
  protocol_type = "HTTP"
}

# 🚀 Create an API Gateway Custom Domain Name
resource "aws_apigatewayv2_domain_name" "api_custom_domain" {
  domain_name = "coach16-urlshortener.sctp-sandbox.com"  # Replace with your custom domain
 
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# 🚀 Create a Base Path Mapping (Link API to Custom Domain)
resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  domain_name = aws_apigatewayv2_domain_name.api_custom_domain.id
  stage       = "$default"
}

# 🚀 Create a Route53 Record to Point to API Gateway
resource "aws_route53_record" "api_gateway_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = aws_apigatewayv2_domain_name.api_custom_domain.domain_name
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.api_custom_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_custom_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}