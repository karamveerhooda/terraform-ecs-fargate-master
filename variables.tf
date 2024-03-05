# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "471112971975.dkr.ecr.us-east-1.amazonaws.com/springboot-example:86199a7a3292129f57212ef71f8e17af82036297"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8080
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 3
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_memory" {
  description = "Fargate instance CPU memory"
  default     = "2048"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "rds_engine" {
  description = "RDS Database Engine"
  default     = "MySQL"
}
variable "rds_instance_class" {
  description = "RDS Database instance type"
  default     = "db.t2.micro"
}
variable "rds_allocated_storage" {
  description = "RDS storage size"
  default     = 10
}
variable "rds_username" {
  description = "RDS DB username"
  default     = "root"
}
variable "rds_password" {
  description = "RDS DB password"
  default     = "password"
}
variable "rds_parameter_group_name" {
  description = "RDS parameter group name"
  default     = "default.mysql8.0"
}
variable "rds_publicly_accessible" {
  description = "RDS access level"
  default     = true
}
variable "rds_skip_final_snapshot" {
  description = "RDS snapshot"
  default     = true
}