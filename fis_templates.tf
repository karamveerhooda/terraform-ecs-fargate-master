/** ====================================================
* AWS FIS ECS Fargate Stop Task Experiment Template - This experiment stops one running ECS task.
* ==================================================== **/
resource "aws_fis_experiment_template" "fis_ecs_stop_task_template" {
  description = "This experiment will stop an ECS Fargate to test resilience."
  role_arn    = aws_iam_role.fis_execution_role.arn

  stop_condition {
    source = "none"
  }

  action {
    name      = "fis_ecs_stop_action"
    action_id = "aws:ecs:stop-task"
    target {
      key   = "Tasks"
      value = "fis_ecs_target"
    }
  }

  target {
    name           = "fis_ecs_target"
    resource_type  = "aws:ecs:task"
    selection_mode = "COUNT(1)" # case sensitive, ALL, COUNT(number), PERCENT(number)
    parameters = {
      cluster = var.ecs_cluster
      service = var.ecs_service
    }
  }

  log_configuration {
    log_schema_version = "2"
    cloudwatch_logs_configuration {
      log_group_arn = "${aws_cloudwatch_log_group.AIOPS_log_group.arn}:*"
    }
  }

  tags = {
    Name  = "AIOPS"
    Value = "POC"
  }
}

/** ====================================================
* AWS FIS ECS Fargate Task CPU Stress Test Experiment Template - This experiment stresses CPU by 50% on all running ECS tasks for 5 minutes.
* ==================================================== **/

resource "aws_fis_experiment_template" "fis_ecs_cpu_stress_test_template" {
  description = "This experiment will stress CPU on all ECS Fargate tasks to test resilience."
  role_arn    = aws_iam_role.fis_execution_role.arn

  stop_condition {
    source = "aws:cloudwatch:alarm"
    value  = "arn:aws:cloudwatch:us-east-2:471112971975:alarm:service_cpu_high"
  }

  action {
    name      = "cpu_stress_5_min"
    action_id = "aws:ecs:task-cpu-stress"
    target {
      key   = "Tasks"
      value = "fis_ecs_cpu_stress_target"
    }

    parameter {
      key   = "duration"
      value = "PT5M" # Run for 5 minutes
    }

    parameter {
      key   = "workers"
      value = "0" # Default is 0, which uses all stressors
    }

    parameter {
      key   = "percent"
      value = "50" # Values from 0 (no load)-100 (full load), Default is 100
    }

  }

  target {
    name           = "fis_ecs_cpu_stress_target"
    resource_type  = "aws:ecs:task"
    selection_mode = "ALL" # case sensitive, ALL, COUNT(number), PERCENT(number)
    parameters = {
      cluster = var.ecs_cluster
      service = var.ecs_service
    }
  }

  log_configuration {
    log_schema_version = "2"
    cloudwatch_logs_configuration {
      log_group_arn = "${aws_cloudwatch_log_group.AIOPS_log_group.arn}:*"
    }
  }

  tags = {
    Name  = "AIOPS"
    Value = "POC"
  }
}

/** ====================================================
* AWS FIS ECS Fargate Task I/O Stress Test Experiment Template - This experiment stresses I/O on all running ECS tasks for 2 minutes.
* ==================================================== **/
resource "aws_fis_experiment_template" "fis_ecs_io_stress_test_template" {
  description = "This experiment will stress IO on all ECS Fargate tasks to test resilience."
  role_arn    = aws_iam_role.fis_execution_role.arn
  stop_condition {
    source = "aws:cloudwatch:alarm"
    value  = "arn:aws:cloudwatch:us-east-2:471112971975:alarm:service_cpu_high"
  }

  action {
    name      = "io_stress_2_min"
    action_id = "aws:ecs:task-io-stress"
    target {
      key   = "Tasks"
      value = "fis_ecs_io_stress_target"
    }
    parameter {
      key   = "duration"
      value = "PT2M" # Run for 2 minutes
    }

    parameter {
      key   = "workers"
      value = "1" # Number of workers for performing I/O operations, default is 1
    }

    parameter {
      key   = "percent"
      value = "50" #  The percent of free space on the file system to use during stress test. Default is 80%
    }
  }

  target {
    name           = "fis_ecs_io_stress_target"
    resource_type  = "aws:ecs:task"
    selection_mode = "ALL" # case sensitive, ALL, COUNT(number), PERCENT(number)
    parameters = {
      cluster = var.ecs_cluster
      service = var.ecs_service
    }
  }

  log_configuration {
    log_schema_version = "2"
    cloudwatch_logs_configuration {
      log_group_arn = "${aws_cloudwatch_log_group.AIOPS_log_group.arn}:*"
    }
  }

  tags = {
    Name  = "AIOPS"
    Value = "POC"
  }
}

/** ====================================================
* AWS FIS RDS Reboot Test Experiment Template - This experiment reboots the RDS DB instance.
* ==================================================== **/
resource "aws_fis_experiment_template" "fis_rds_reboot_test_template" {
  description = "This experiment will reboot the RDS instance to test resilience."
  role_arn    = aws_iam_role.fis_execution_role.arn
  stop_condition {
    source = "none"
  }

  action {
    name      = "rds_reboot_action"
    action_id = "aws:rds:reboot-db-instances"
    target {
      key   = "DBInstances"
      value = "fis_rds_target"
    }
  }

  target {
    name           = "fis_rds_target"
    resource_type  = "aws:rds:db"
    selection_mode = "COUNT(1)" # case sensitive, ALL, COUNT(number), PERCENT(number)
    resource_tag {
      key   = "devops-guru-aiops"
      value = "cap"
    }
  }

  log_configuration {
    log_schema_version = "2"
    cloudwatch_logs_configuration {
      log_group_arn = "${aws_cloudwatch_log_group.AIOPS_log_group.arn}:*"
    }
  }

  tags = {
    Name  = "AIOPS"
    Value = "POC"
  }
}