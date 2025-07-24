provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-app-sg-2"
  description = "Allow SSH, HTTP, HTTPS, and Strapi"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your actual IP
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
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
}

resource "aws_instance" "strapi" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y docker.io
    systemctl start docker
    systemctl enable docker

    docker network create strapi-net

    docker run -d --name postgres --network strapi-net \
      -e POSTGRES_DB=strapi \
      -e POSTGRES_USER=strapi \
      -e POSTGRES_PASSWORD=pass123 \
      -v /srv/pgdata:/var/lib/postgresql/data \
      postgres:15

    docker pull rutikgawali1/strapi-app:latest

    docker run -d --name strapi --network strapi-net \
      -e DATABASE_CLIENT=postgres \
      -e DATABASE_HOST=postgres \
      -e DATABASE_PORT=5432 \
      -e DATABASE_NAME=strapi \
      -e DATABASE_USERNAME=strapi \
      -e DATABASE_PASSWORD=pass123 \
      -e APP_KEYS=Rd4EZ4S13CKp1JlAMzxk5A==,R4GDtWxkpBkJuK2Aq4Pv7g==,Q7df6Erx8xr6N6QFwlT4ig==,DUQwEBTNfE5qamNS1y97Xw== \
      -e API_TOKEN_SALT=y6QBwgHTWetn4KoRl7MDTA== \
      -e ADMIN_JWT_SECRET=IbscCljtmC/t/KWWOFYOAg== \
      -p 1337:1337 \
      rutikgawali1/strapi-app:latest
  EOF

  tags = {
    Name = "strapi-rutik"
  }
}


