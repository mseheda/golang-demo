resource "aws_instance" "silly_demo" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.silly_demo_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx golang
              systemctl enable nginx
              systemctl start nginx
              mkdir -p /home/ubuntu/silly-demo
              cd /home/ubuntu/silly-demo
              git clone https://github.com/<your-username>/golang-demo.git
              cd golang-demo
              go build -o silly-demo
              ./silly-demo &
              echo "server {
                  listen 80;
                  location / {
                      proxy_pass http://localhost:8080;
                  }
              }" > /etc/nginx/sites-available/default
              systemctl restart nginx
              EOF

  tags = {
    Name = "silly-demo-ec2"
  }
}
