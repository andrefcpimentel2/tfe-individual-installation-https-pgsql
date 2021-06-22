resource "random_pet" "replicated-pwd" {
  length = 4
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "random_password" "tfe_initial_password" {
  length = 16
  special = true
  min_upper = 1
  min_lower = 1
  min_special = 1
  min_numeric  = 1
  override_special = "_%@#"
}

# data "template_file" "user_data" {
#   template = file("user-data.tpl")

#   vars = {
#     hostname       = "tfe.${var.namespace}.hashidemos.io"
#     enc_password = random_pet.replicated-pwd.id
#     daemon_password = random_password.password.result
#     ca_key = file(var.ca_key_file)
#     ca_cert = file(var.ca_cert_file)
#     license = filebase64(var.license_file)
#   }
# }


locals {
  fqdn = "tfe.${var.namespace}.${substr(data.aws_route53_zone.fdqn.name,0,length(data.aws_route53_zone.fdqn.name)-1)}"
  

  }

resource "aws_instance" "tfe" {

  ami           = var.ami
  instance_type = var.instance_type_worker
  key_name      = aws_key_pair.deployer.key_name
  associate_public_ip_address  = true
  user_data     = templatefile("user-data.sh", {
      hostname       = local.fqdn,
      enc_password = random_pet.replicated-pwd.id,
      daemon_password = random_password.password.result,
      license = filebase64(var.license_file),
      pg_dbname                 = "${var.namespace}pes",
      pg_netloc                 = aws_db_instance.ptfe.endpoint,
      pg_password               = random_password.db_password.result,
      pg_user                   = var.database_username,
      pg_address                = aws_db_instance.ptfe.address,
      s3_bucket                 = aws_s3_bucket.pes.id,
      s3_region                 = aws_s3_bucket.pes.region,
      initial_admin_username    = var.initial_admin_username,
      initial_admin_email       = var.initial_admin_email,
      initial_admin_password    = random_password.tfe_initial_password.result
  })
  subnet_id              = aws_subnet.tfe_subnet[0].id
  vpc_security_group_ids = [aws_security_group.tfe_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ptfe.name


  root_block_device{
    volume_size           = "50"
    delete_on_termination = "true"
  }

   ebs_block_device  {
    device_name           = "/dev/xvdd"
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = "true"
  }


  tags = {
    Name       = "${var.namespace}-tfe"
    owner      = var.owner
    created-by = var.created-by
  }
}



### S3 bucket resorces

resource "aws_s3_bucket" "pes" {
  bucket = "${var.namespace}-tfe-s3bucket"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name       = "${var.namespace}-tfe-s3bucket"
    owner      = var.owner
    created-by = var.created-by
  }

}

# IAM resources

resource "aws_iam_role" "ptfe" {
  name = "${var.namespace}-iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ptfe" {
  name = "${var.namespace}-iam_instance_profile"
  role = aws_iam_role.ptfe.name
}

#Policies here: S3 access for TFE storage and STS assume role for Workspaces to assume role instead of having IAM user keys
data "aws_iam_policy_document" "ptfe" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.pes.id}",
      "arn:aws:s3:::${aws_s3_bucket.pes.id}/*",
    ]

    actions = [
      "s3:*",
    ]
  }
  statement {
    sid    = "listBuckets"
    effect = "Allow"

    resources = [
      "*"
    ]

    actions = [
       "s3:ListAllMyBuckets",
       "s3:ListBucket",
       "s3:HeadBucket"
    ]
  }
  statement {
    sid    = "AssumeRole"
    effect = "Allow"

    resources = [
      "*"
    ]

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role_policy" "ptfe" {
  name   = "${var.namespace}-iam_role_policy"
  role   = aws_iam_role.ptfe.name
  policy = data.aws_iam_policy_document.ptfe.json
}
