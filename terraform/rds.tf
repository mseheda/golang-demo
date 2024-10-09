resource "aws_db_instance" "silly_demo_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t4g.micro"
  db_name                 = "sillydemodb"
  username             = "dbadmin"
  password             = "12345678"
  parameter_group_name = "default.postgres13"
  publicly_accessible  = false
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.silly_demo_subnet_group.name

  tags = {
    Name = "silly-demo-db"
  }
}

resource "aws_db_subnet_group" "silly_demo_subnet_group" {
  name       = "silly-demo-db-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id, aws_subnet.subnet_c.id]

  tags = {
    Name = "silly-demo-db-subnet-group"
  }
}
