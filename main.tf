provider "aws" {
  region = "us-east-1"
}

variable "instance_count" {
  default = 2
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI"
  default     = "ami-06b21ccaeff8cd686"
}

resource "aws_security_group" "silly_demo_sg" {
  name        = "silly-demo-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "silly_demo" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.silly_demo_sg.name]
  user_data     = file("userdata.sh") # my own script

  tags = {
    Name = "silly-demo-${count.index + 1}"
  }
}

resource "aws_lb" "silly_demo_lb" {
  name               = "silly-demo-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.silly_demo_sg.id]
  subnets            = ["subnet-0553244e75a26376c", "subnet-0a9befe8cbeefaa71"]
}

resource "aws_lb_target_group" "silly_demo_tg" {
  name     = "silly-demo-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0abeebb898e64407d"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "silly_demo_attach" {
  for_each = aws_instance.silly_demo
  target_group_arn = aws_lb_target_group.silly_demo_tg.arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.silly_demo_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.silly_demo_tg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.silly_demo_lb.dns_name
}
