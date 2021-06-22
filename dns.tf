

resource "aws_route53_record" "tfe_lb" {
  zone_id = var.zone_id
   name    = "tfe.${var.namespace}"
  type    = "CNAME"
  records = [aws_alb.tfe.dns_name]
  ttl     = "300"
}

resource "aws_route53_record" "tfe_instance" {
  zone_id = var.zone_id
  name    = "tfe-instance.${var.namespace}"
  type    = "CNAME"
  records = [aws_instance.tfe.public_ip]
  ttl     = "300"
}

