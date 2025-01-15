
resource "aws_instance" "web_server" {
  count         = 2
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, count.index)
  security_groups = [aws_security_group.web_sg.id]
  monitoring = true
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  tags = {
    Name = "${var.name_prefix}-${count.index}"
  }
  user_data = <<-EOF
    #!/bin/bash
    yum update -y

    amazon-linux-extras enable nginx1
    yum install -y nginx

    systemctl enable nginx
    systemctl start nginx

    yum install -y aws-cli

    aws s3 cp s3://zura-task-bucket/index.html /usr/share/nginx/html/index.html

    systemctl restart nginx
  EOF
}

resource "aws_security_group" "web_sg" {
  name        = "${var.name_prefix}-sg"
  description = "Allow SSH, HTTP, and HTTPS traffic"
  vpc_id      = var.vpc_id

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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "${var.name_prefix}-sg"
  }
}

resource "aws_eip" "vip" {
  tags = {
    Name = "web-server-vip"
  }
}

resource "aws_eip_association" "eip_to_active_instance" {
  instance_id   = aws_instance.web_server[0].id
  allocation_id = aws_eip.vip.id
}
resource "aws_iam_role" "ec2_s3_access" {
  name               = "ec2-s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_read_access" {
  name   = "s3-read-access-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:GetObject"],
        Effect   = "Allow",
        Resource = ["arn:aws:s3:::zura-task-bucket/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_access" {
  role       = aws_iam_role.ec2_s3_access.name
  policy_arn = aws_iam_policy.s3_read_access.arn
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.ec2_s3_access.name
}
