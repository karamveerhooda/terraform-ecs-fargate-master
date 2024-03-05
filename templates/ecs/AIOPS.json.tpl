[
  {
    "name": "AIOPS",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/AIOPS",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ]
     environment = [
      { name = "DB_HOST", value = module.rds.rds_endpoint },
      { name = "DB_USER", value = "your_db_user" },
      { name = "DB_PASSWORD", value = "your_db_password" },
      { name = "DB_NAME", value = "your_db_name" },
    ]
  }
]