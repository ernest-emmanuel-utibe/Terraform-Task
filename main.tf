terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"  # Change this to your preferred region
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "webserver-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "webserver-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "webserver-public-subnet"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "webserver-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "webserver" {
  name        = "webserver-sg"
  description = "Security group for web server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver-sg"
  }
}

# EC2 Instance
resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.webserver.id]

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y
              
              # Install Apache
              yum install -y httpd
              
              
              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>My Web Server</title>
                  <style>
                      body {
                          font-family: Arial, sans-serif;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          height: 100vh;
                          margin: 0;
                          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                      }
                      .container {
                          text-align: center;
                          background: white;
                          padding: 50px;
                          border-radius: 10px;
                          box-shadow: 0 10px 30px rgba(0,0,0,0.3);
                      }
                      h1 {
                          color: #333;
                          margin: 0;
                          font-size: 2.5em;
                      }
                      p {
                          color: #666;
                          margin-top: 20px;
                          font-size: 1.2em;
                      }
                  </style>
              </head>
              <body>
                  <div class="container">   
                      <h1>ERNEST EMMANUEL UTIBE</h1>
                      <p>Welcome to my AWS web server provisioned with Terraform!</p>
                  </div>
              </body>
              </html>
              HTML
              
              # Start and enable Apache
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "terraform-webserver"
  }
}

# Outputs
output "public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.webserver.public_ip
}

output "public_dns" {
  description = "Public DNS name of the web server"
  value       = aws_instance.webserver.public_dns
}

output "website_url" {
  description = "URL to access the website"
  value       = "http://${aws_instance.webserver.public_ip}"
}