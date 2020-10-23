locals {
  programmatic_users = [
    "femiwiki-email",
    "terraform-cloud",
    "packer",
  ]
}

resource "aws_iam_account_password_policy" "strict" {
  allow_users_to_change_password = true
  minimum_password_length        = 14
}


#
# IAM Users
#
resource "aws_iam_user" "programmatic_users" {
  for_each = toset(local.programmatic_users)
  name     = each.key
}

resource "aws_iam_user_policy_attachment" "terraform_cloud" {
  user       = "terraform-cloud"
  policy_arn = aws_iam_policy.terraform_cloud.arn
}

resource "aws_iam_user_policy_attachment" "packer" {
  user       = "packer"
  policy_arn = aws_iam_policy.packer.arn
}

resource "aws_iam_user_policy" "ses_sending_access" {
  name   = "AmazonSesSendingAccess"
  user   = "femiwiki-email"
  policy = data.aws_iam_policy_document.ses_sending_access.json
}

data "aws_iam_policy_document" "ses_sending_access" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}


#
# IAM Groups
#
resource "aws_iam_group" "admin" {
  name = "Admin"
}

resource "aws_iam_group_policy_attachment" "admin_permission" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # AWS managed policy
}

resource "aws_iam_group_policy_attachment" "admin_mfa" {
  group      = aws_iam_group.admin.name
  policy_arn = aws_iam_policy.force_mfa.arn
}

resource "aws_iam_group" "readonly" {
  name = "ReadOnly"
}

resource "aws_iam_group_policy_attachment" "readonly_permission" {
  group      = aws_iam_group.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" # AWS managed policy
}

resource "aws_iam_group_policy_attachment" "readonly_mfa" {
  group      = aws_iam_group.readonly.name
  policy_arn = aws_iam_policy.force_mfa.arn
}


#
# IAM Roles
#
resource "aws_iam_role" "femiwiki" {
  name               = "Femiwiki"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json
}

data "aws_iam_policy_document" "instance_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "femiwiki" {
  name = "Femiwiki"
  role = aws_iam_role.femiwiki.name
}

resource "aws_iam_role_policy_attachment" "femiwiki_amazon_s3_access" {
  role       = aws_iam_role.femiwiki.name
  policy_arn = aws_iam_policy.amazon_s3_access.arn
}

resource "aws_iam_role_policy_attachment" "femiwiki_route53" {
  role       = aws_iam_role.femiwiki.name
  policy_arn = aws_iam_policy.route53.arn
}

resource "aws_iam_role_policy_attachment" "femiwiki_upload_backup" {
  role       = aws_iam_role.femiwiki.name
  policy_arn = aws_iam_policy.upload_backup.arn
}

resource "aws_iam_role_policy_attachment" "femiwiki_mount_ebs_volumes" {
  role       = aws_iam_role.femiwiki.name
  policy_arn = aws_iam_policy.mount_ebs_volumes.arn
}
