
resource "aws_instance" "web_server" {
  count         = 2
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, count.index)
  security_groups = [aws_security_group.web_sg.id]
  monitoring = true

  tags = {
    Name = "${var.name_prefix}-${count.index}"
  }
  user_data = <<-EOF
    #!/bin/bash
    # Update the package list
    yum update -y

    # Install Nginx
    amazon-linux-extras enable nginx1
    yum install -y nginx

    # Enable and start the Nginx service
    systemctl enable nginx
    systemctl start nginx

    # Create a custom index.html for verification
    echo "Welcome to Web Server ${count.index}!" > /usr/share/nginx/html/index.html
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
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
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