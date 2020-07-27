#S2 assume role

resource "aws_iam_role" "ec2_iam_assumed_role" {
  name = "${var.namespace}-Ec2AssumeRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.ptfe.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "ec2_iam_assumed_policy" {
  name = "EC2Deployment"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "transitgateway.amazonaws.com"
                    ]
                }
            }
        }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ec2_iam_attach_role" {
  role       = aws_iam_role.ec2_iam_assumed_role.name
  policy_arn = aws_iam_policy.ec2_iam_assumed_policy.arn
}




#S3 assumed role

resource "aws_iam_role" "s3_iam_assumed_role" {
  name = "${var.namespace}-s3AssumeRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.ptfe.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "s3_iam_assumed_policy" {
  name = "S3Deployment"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Action": "s3:*",
            "Effect": "Allow",
            "Resource": "*"
        }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "s3_iam_attach_role" {
  role       = aws_iam_role.s3_iam_assumed_role.name
  policy_arn = aws_iam_policy.s3_iam_assumed_policy.arn
}

#EKS Cluster role

# resource "aws_iam_role" "eks_iam_assumed_role" {
#   name = "${var.namespace}-eksAssumeRole"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "${aws_iam_role.ptfe.arn}"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }


# resource "aws_iam_policy" "eks_iam_assumed_policy" {
#   name = "eksDeployment"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#             "Action": [
#             "eks:*",
#             "ec2:*",
#              "iam:*"
#             ],
#             "Effect": "Allow",
#             "Resource": "*"
#         }
#   ]
# }
# EOF
# }


# resource "aws_iam_role_policy_attachment" "eks_iam_attach_role" {
#   role       = aws_iam_role.eks_iam_assumed_role.name
#   policy_arn = aws_iam_policy.eks_iam_assumed_policy.arn
# }