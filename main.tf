resource "random_pet" "replicated-pwd" {
  length = 4
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
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

resource "aws_instance" "tfe" {

  ami           = var.ami
  instance_type = var.instance_type_worker
  key_name      = aws_key_pair.deployer.key_name
  user_data     = templatefile("user-data.sh", {
      hostname       = "tfe.${var.namespace}.hashidemos.io",
      enc_password = random_pet.replicated-pwd.id,
      daemon_password = random_password.password.result,
      license = filebase64(var.license_file)
  })
  subnet_id              = aws_subnet.tfe_subnet[0].id
  vpc_security_group_ids = [aws_security_group.tfe_sg.id]


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
resource "aws_eip" "ptfe" {
  instance = aws_instance.tfe.id
}



# ### S3 bucket resorces

# data "aws_kms_key" "s3" {
#   key_id = "${var.kms_key_id}"
# }

# resource "aws_s3_bucket" "pes" {
#   bucket        = "${var.ptfe_bucket_name}"
#   acl           = "private"
#   force_destroy = true

#   versioning {
#     enabled = true
#   }

#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         kms_master_key_id = "${data.aws_kms_key.s3.arn}"
#         sse_algorithm     = "aws:kms"
#       }
#     }
#   }

#   tags {
#     Name = "${var.ptfe_bucket_name}"
#   }

# }

# # IAM resources

# resource "aws_iam_role" "ptfe" {
#   name = "${var.namespace}-iam_role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_instance_profile" "ptfe" {
#   name = "${var.namespace}-iam_instance_profile"
#   role = "${aws_iam_role.ptfe.name}"
# }

# data "aws_iam_policy_document" "ptfe" {
#   statement {
#     sid    = "AllowS3"
#     effect = "Allow"

#     resources = [
#       "arn:aws:s3:::${aws_s3_bucket.pes.id}",
#       "arn:aws:s3:::${aws_s3_bucket.pes.id}/*",
#       "arn:aws:s3:::${var.source_bucket_id}",
#       "arn:aws:s3:::${var.source_bucket_id}/*",
#     ]

#     actions = [
#       "s3:*",
#     ]
#   }

#   statement {
#     sid    = "AllowKMS"
#     effect = "Allow"

#     resources = [
#       "${data.aws_kms_key.s3.arn}",
#     ]

#     actions = [
#       "kms:Decrypt",
#       "kms:Encrypt",
#       "kms:DescribeKey",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#     ]
#   }
# }

# resource "aws_iam_role_policy" "ptfe" {
#   name   = "${var.namespace}-iam_role_policy"
#   role   = "${aws_iam_role.ptfe.name}"
#   policy = "${data.aws_iam_policy_document.ptfe.json}"
# }