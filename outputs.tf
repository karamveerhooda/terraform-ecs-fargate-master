
# outputs.tf

output "alb_hostname" {
  value = aws_alb.main.dns_name
}

output "stop_task_experiment_id" {
  value = aws_fis_experiment_template.fis_ecs_stop_task_template.id
}

output "cpu_stress_experiment_id" {
  value = aws_fis_experiment_template.fis_ecs_cpu_stress_test_template.id
}

output "io_stress_experiment_id" {
  value = aws_fis_experiment_template.fis_ecs_io_stress_test_template.id
}

output "rds_reboot_experiment_id" {
  value = aws_fis_experiment_template.fis_rds_reboot_test_template.id
}