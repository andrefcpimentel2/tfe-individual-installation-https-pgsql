resource "aws_alb" "tfe" {
  name = "${var.namespace}-tfe"

  security_groups = [aws_security_group.tfe_sg.id]
  subnets         = aws_subnet.tfe_subnet.*.id

  tags = {
    Name           = "${var.namespace}-tfe"
    owner          = var.owner
    created-by     = var.created-by
    sleep-at-night = var.sleep-at-night
    TTL            = var.TTL
  }
}

resource "aws_alb_target_group" "tfe" {
  name = "${var.namespace}-tfe"

  port     = "443"
  vpc_id   = aws_vpc.tfe_vpc.id
  protocol = "HTTPS"
}

resource "aws_alb_listener" "tfe" {
  depends_on = [
    aws_acm_certificate_validation.cert
  ]

  load_balancer_arn = aws_alb.tfe.arn

  port     = "443"
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  default_action {
    target_group_arn = aws_alb_target_group.tfe.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "tfe" {
  target_group_arn = aws_alb_target_group.tfe.arn
  target_id        = aws_instance.tfe.id
  port             = "443"
}


resource "aws_alb_target_group" "tfe2" {
  name = "${var.namespace}-tfe2"

  port     = "8800"
  vpc_id   = aws_vpc.tfe_vpc.id
  protocol = "HTTPS"
}

resource "aws_alb_listener" "tfe2" {

  load_balancer_arn = aws_alb.tfe.arn

  port     = "8800"
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  default_action {
    target_group_arn = aws_alb_target_group.tfe2.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "tfe2" {
  target_group_arn = aws_alb_target_group.tfe2.arn
  target_id        = aws_instance.tfe.id
  port             = "8800"
}