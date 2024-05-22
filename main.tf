provider "aws" {
  region = "ap-south-1"  # Change this to your desired region
}

# Define a Security Group
resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Allow SSH and HTTP traffic"


  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define an EC2 instance
resource "aws_instance" "example_instance" {
  ami           = "ami-0f58b397bc5c1f2e8" 
  instance_type = "t2.micro"
 

  security_groups = [aws_security_group.example_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y \
                  apt-transport-https \
                  ca-certificates \
                  curl \
                  gnupg \
                  lsb-release
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              apt-get update
              apt-get install -y docker-ce docker-ce-cli containerd.io
              curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              usermod -aG docker ubuntu
            EOF

  tags = {
    Name = "example-instance"
  }
}

