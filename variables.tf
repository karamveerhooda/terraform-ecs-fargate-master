# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-2"
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
  default     = "471112971975.dkr.ecr.us-east-2.amazonaws.com/springboot-example:504dc2de748c0984272d6c0576f6164c6637a2c3"
  #471112971975.dkr.ecr.us-east-1.amazonaws.com/springboot-example:bea9be38fbac64a607e153de7b59c7d6b3e94b3f
  #471112971975.dkr.ecr.us-east-1.amazonaws.com/springboot-example:3da21950addf9c14412b27b32809bcff527041bf
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8080
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 2
}

variable "health_check_path" {
  default = "/employees"
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
  default     = "db.t3.micro"
}
variable "rds_allocated_storage" {
  description = "RDS storage size"
  default     = 10
}
variable "rds_username" {
  description = "RDS DB username"
  default     = "aiops"
}
variable "rds_password" {
  description = "RDS DB password"
  default     = "capgemini"
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
variable "ecs_task_role_name" {
  description = "ECS task role name"
  default     = "myEcsTaskRole"
}

variable "ecs_ssm_policy" {
  description = "ECS SSM Policy"
  default     = "ECSSSMPolicy"
}

variable "fis_tests_active" {
  type        = bool
  description = "Enable SSM for FIS Tests"
  default     = true
}

variable "ssm_register_instance_role" {
  description = "Role given to SSM to register tasks with SSM"
  default     = "SSMRegisterInstanceRole"
}

variable "ecs_ssm_deregister_policy" {
  description = "Permissions given to SSM to deregister tasks with SSM"
  default     = "SSMDeRegisterPolicy"
}



