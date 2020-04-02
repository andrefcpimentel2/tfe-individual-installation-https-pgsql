

# Client private key

resource "tls_private_key" "tfe" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "tls_self_signed_cert" "tfe" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.tfe.private_key_pem

  subject {
    common_name  = "tfe.${var.namespace}.${data.aws_route53_zone.fdqn.name}"
    organization = "HashiCorp Demostack"
  }

  validity_period_hours = 720

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "server_auth",
  ]
}

# Client signing request
resource "tls_cert_request" "tfe" {
  key_algorithm   = tls_private_key.tfe.algorithm
  private_key_pem = tls_private_key.tfe.private_key_pem

  subject {
    common_name  = "${var.namespace}.${data.aws_route53_zone.fdqn.name}"
    organization = "HashiCorp Demostack"
  }

  dns_names = [
    # tfe
    "tfe-instance.${var.namespace}.${data.aws_route53_zone.fdqn.name}",
    "tfe.${var.namespace}.${data.aws_route53_zone.fdqn.name}",
    # Common
    "localhost",
    "*.${var.namespace}.${data.aws_route53_zone.fdqn.name}",
  ]

}

# Client certificate

resource "tls_locally_signed_cert" "workers" {
  cert_request_pem = tls_cert_request.tfe.cert_request_pem

  ca_key_algorithm = var.ca_key_algorithm
  ca_private_key_pem = tls_private_key.tfe.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.tfe.cert_pem

  validity_period_hours = 720 # 30 days

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "server_auth",
  ]
}


// ALB certs
resource "aws_acm_certificate" "cert" {
   domain_name       = "*.${var.namespace}.${data.aws_route53_zone.fdqn.name}"
  validation_method = "DNS"

  tags = {
    Name           = "${var.namespace}-tfe"
    owner          = var.owner
    created-by     = var.created-by
    sleep-at-night = var.sleep-at-night
    TTL            = var.TTL
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation_record" {
  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = var.zone_id
  records = [ aws_acm_certificate.cert.domain_validation_options.0.resource_record_value ]
  ttl     = "60"
  allow_overwrite = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    aws_route53_record.validation_record.fqdn,
  ]
}
