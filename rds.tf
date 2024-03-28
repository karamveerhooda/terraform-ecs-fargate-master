#AWS DB Subnet group
resource "aws_db_subnet_group" "example" {
  name       = "main"
  subnet_ids = aws_subnet.private.*.id
  tags = {
    Name  = "AIOPS"
    Value = "POC"
  }
}

#RDS.tf
resource "aws_db_instance" "rds_instance" {
  instance_class = var.rds_instance_class
  engine         = var.rds_engine
  engine_version = "8.0.28"
  # other RDS configuration...
  db_name                = "employeemanagementsystem"
  identifier             = "employeemanagementsystem"
  allocated_storage      = var.rds_allocated_storage
  username               = var.rds_username
  password               = var.rds_password
  parameter_group_name   = var.rds_parameter_group_name
  publicly_accessible    = var.rds_publicly_accessible
  vpc_security_group_ids = [aws_security_group.lb.id]
  skip_final_snapshot    = var.rds_skip_final_snapshot
  db_subnet_group_name   = aws_db_subnet_group.example.name

}
output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}



