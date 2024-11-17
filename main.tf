provider "aws" {
  region = "eu-north-1"
}

resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"
  description = "Allow HTTP and SSH traffic"

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

resource "aws_launch_template" "app_template" {
  name_prefix = "silly-demo-lt-"

  image_id      = "ami-08eb150f611ca277f"
  instance_type = "t3.micro"

  key_name = "kube-hw-kp" 

  user_data = <<-EOT
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras enable nginx1
              sudo yum install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "<h1>Silly Demo</h1>" | sudo tee /usr/share/nginx/html/index.html

              # Install Go and Run silly-demo app
              sudo yum install -y golang
              cd /home/ec2-user
              echo 'package main; import "fmt"; func main() { fmt.Println("Silly Demo App Running") }' > main.go
              go build -o silly-demo main.go
              chmod +x silly-demo
              ./silly-demo &
              EOT
}

resource "aws_autoscaling_group" "app_asg" {
  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  min_size = 1
  desired_capacity = 1
  max_size = 2

  vpc_zone_identifier = ["subnet-0a12b34c56d78e9f0"] 
  target_group_arns   = [aws_lb_target_group.app_tg.arn]

  tags = [
    {
      key                 = "Name"
      value               = "Silly-Demo-Instance"
      propagate_at_launch = true
    }
  ]
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = ["subnet-0a12b34c56d78e9f0"]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0a12b34c56d78e9f0" # Replace with your VPC ID
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
