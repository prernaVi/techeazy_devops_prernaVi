
provider "aws" {
  region = var.aws_region
}

# IAM Role A: Read-only on S3
resource "aws_iam_role" "s3_readonly_role" {
  name = "techeazy-s3-readonly-role"
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role_policy.json
}

resource "aws_iam_policy" "s3_readonly_policy" {
  name        = "techeazy-s3-readonly-policy"
  description = "Read-only access to S3"
  policy      = data.aws_iam_policy_document.s3_read_policy.json
}

resource "aws_iam_role_policy_attachment" "readonly_attach" {
  role       = aws_iam_role.s3_readonly_role.name
  policy_arn = aws_iam_policy.s3_readonly_policy.arn
}

# IAM Role B: Write-only on S3
resource "aws_iam_role" "s3_writeonly_role" {
  name = "techeazy-s3-writeonly-role"
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role_policy.json
}

resource "aws_iam_policy" "s3_writeonly_policy" {
  name        = "techeazy-s3-writeonly-policy"
  description = "Write-only access to S3"
  policy      = data.aws_iam_policy_document.s3_write_policy.json
}

resource "aws_iam_role_policy_attachment" "writeonly_attach" {
  role       = aws_iam_role.s3_writeonly_role.name
  policy_arn = aws_iam_policy.s3_writeonly_policy.arn
}

# IAM Instance Profile for Role B
resource "aws_iam_instance_profile" "writeonly_profile" {
  name = "techeazy-s3-writeonly-profile"
  role = aws_iam_role.s3_writeonly_role.name
}

# Policies
data "aws_iam_policy_document" "s3_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_read_policy" {
  statement {
    actions = ["s3:ListBucket", "s3:GetObject"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "s3_write_policy" {
  statement {
    actions = ["s3:PutObject", "s3:CreateBucket"]
    resources = ["*"]
  }
}

# S3 Bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket = var.bucket_name

  acl    = "private"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 7
    }
  }

  force_destroy = true
}

# Security Group
resource "aws_security_group" "instance_sg" {
  name        = "techeazy-instance-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "techeazy_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.writeonly_profile.name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "techeazy-devops-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install java-openjdk11 -y
              yum install -y git awscli

              # Clone and run app
              git clone ${var.repo_url} app || true
              cd app
              chmod +x scripts/start.sh || true
              ./scripts/start.sh --port 80 || true

              # Setup shutdown hook for log upload
              echo '
              #!/bin/bash
              aws s3 cp /var/log/cloud-init.log s3://${var.bucket_name}/ec2-logs/cloud-init.log
              if [ -d /app/logs ]; then
                  aws s3 cp /app/logs s3://${var.bucket_name}/app/logs/ --recursive
              fi
              ' > /usr/local/bin/upload_logs.sh
              chmod +x /usr/local/bin/upload_logs.sh

              echo "/usr/local/bin/upload_logs.sh" >> /etc/rc.d/rc.local
              chmod +x /etc/rc.d/rc.local

              shutdown -h +${var.shutdown_after_minutes}
              EOF
}

# Verification block (runs locally)
resource "null_resource" "verify_upload" {
  provisioner "local-exec" {
    command = "echo 'Waiting 4 min for instance shutdown and upload...' && sleep 240 && aws s3 ls s3://${var.bucket_name}/ > verification_log.txt && echo 'Verification completed. Check verification_log.txt'"
  }

  depends_on = [aws_instance.techeazy_instance]
}
