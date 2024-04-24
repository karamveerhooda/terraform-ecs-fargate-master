# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "DevClusterTerraform"
  tags = {
    Environment = "AIOPS"
    Project     = "POC"
  }
}

/*data "template_file" "AIOPS" {
  template = file("./templates/ecs/AIOPS.json.tpl")

  vars = {
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}*/

resource "aws_ecs_task_definition" "app" {
  family                   = "springboot-app-task-definition"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = var.fis_tests_active ? "[${local.springboot_app}, ${local.amazon_ssm_agent}]" : "[${local.springboot_app}]"
  /*container_definitions = jsonencode([{
    name  = "springboot-example"
    image = var.app_image
    portMappings = [{
      containerPort = var.app_port,
      hostPort      = var.app_port,
    }]

    environment = [
      #{ name = "DB_HOST", value = "${aws_db_instance.rds_instance.endpoint}:${aws_db_instance.rds_instance.port}" },
      { name = "DB_HOST", value = "${aws_db_instance.rds_instance.endpoint}" },
      { name = "DB_USER", value = "aiops" },
      { name = "DB_PASSWORD", value = "capgemini" },
      { name = "DB_NAME", value = "terraform" },
    ]
  }])*/
  tags = {
    Environment = "AIOPS"
    Project     = "POC"
    devops-guru-aiops = "cap"
  }
  depends_on = [aws_db_instance.rds_instance]
}

resource "aws_ecs_service" "main" {
  name            = "springboot-example-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "springboot-example"
    container_port   = var.app_port
  }
  tags = {
    Environment = "AIOPS"
    Project     = "POC"
    devops-guru-aiops = "cap"
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role_policy1, aws_iam_role_policy_attachment.ecs_task_execution_role_policy2]
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_service.main.cluster}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_scaling_policy" {
  name               = "ecs-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 40
  }
}

locals {

  springboot_app = jsonencode(
    {
      name  = "springboot-example",
      image = var.app_image,
      portMappings = [{
        containerPort = var.app_port,
        hostPort      = var.app_port
      }],
      environment = [
        #{ name = "DB_HOST", value = "${aws_db_instance.rds_instance.endpoint}:${aws_db_instance.rds_instance.port}" },
        { name = "DB_HOST", value = "${aws_db_instance.rds_instance.endpoint}" },
        { name = "DB_USER", value = "aiops" },
        { name = "DB_PASSWORD", value = "capgemini" },
        { name = "DB_NAME", value = "terraform" }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.AIOPS_log_group.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "ecs-dev"
        }
      }
    }
  )

  amazon_ssm_agent = jsonencode(
    {
      name         = "amazon-ssm-agent",
      image        = "public.ecr.aws/amazon-ssm-agent/amazon-ssm-agent:latest",
      cpu          = 0,
      links        = [],
      portMappings = [],
      essential    = false,
      entryPoint   = [],
      command = [
        "/bin/bash",
        "-c",
        "set -e; yum upgrade -y; yum install jq procps awscli -y; term_handler() { echo \"Deleting SSM activation $ACTIVATION_ID\"; if ! aws ssm delete-activation --activation-id $ACTIVATION_ID --region $ECS_TASK_REGION; then echo \"SSM activation $ACTIVATION_ID failed to be deleted\" 1>&2; fi; MANAGED_INSTANCE_ID=$(jq -e -r .ManagedInstanceID /var/lib/amazon/ssm/registration); echo \"Deregistering SSM Managed Instance $MANAGED_INSTANCE_ID\"; if ! aws ssm deregister-managed-instance --instance-id $MANAGED_INSTANCE_ID --region $ECS_TASK_REGION; then echo \"SSM Managed Instance $MANAGED_INSTANCE_ID failed to be deregistered\" 1>&2; fi; kill -SIGTERM $SSM_AGENT_PID; }; trap term_handler SIGTERM SIGINT; if [[ -z $MANAGED_INSTANCE_ROLE_NAME ]]; then echo \"Environment variable MANAGED_INSTANCE_ROLE_NAME not set, exiting\" 1>&2; exit 1; fi; if ! ps ax | grep amazon-ssm-agent | grep -v grep > /dev/null; then if [[ -n $ECS_CONTAINER_METADATA_URI_V4 ]] ; then echo \"Found ECS Container Metadata, running activation with metadata\"; TASK_METADATA=$(curl \"$${ECS_CONTAINER_METADATA_URI_V4}/task\"); ECS_TASK_AVAILABILITY_ZONE=$(echo $TASK_METADATA | jq -e -r '.AvailabilityZone'); ECS_TASK_ARN=$(echo $TASK_METADATA | jq -e -r '.TaskARN'); ECS_TASK_REGION=$(echo $ECS_TASK_AVAILABILITY_ZONE | sed 's/.$//'); ECS_TASK_AVAILABILITY_ZONE_REGEX='^(af|ap|ca|cn|eu|me|sa|us|us-gov)-(central|north|(north(east|west))|south|south(east|west)|east|west)-[0-9]{1}[a-z]{1}$'; if ! [[ $ECS_TASK_AVAILABILITY_ZONE =~ $ECS_TASK_AVAILABILITY_ZONE_REGEX ]]; then echo \"Error extracting Availability Zone from ECS Container Metadata, exiting\" 1>&2; exit 1; fi; ECS_TASK_ARN_REGEX='^arn:(aws|aws-cn|aws-us-gov):ecs:[a-z0-9-]+:[0-9]{12}:task/[a-zA-Z0-9_-]+/[a-zA-Z0-9]+$'; if ! [[ $ECS_TASK_ARN =~ $ECS_TASK_ARN_REGEX ]]; then echo \"Error extracting Task ARN from ECS Container Metadata, exiting\" 1>&2; exit 1; fi; CREATE_ACTIVATION_OUTPUT=$(aws ssm create-activation --iam-role $MANAGED_INSTANCE_ROLE_NAME --tags Key=ECS_TASK_AVAILABILITY_ZONE,Value=$ECS_TASK_AVAILABILITY_ZONE Key=ECS_TASK_ARN,Value=$ECS_TASK_ARN Key=FAULT_INJECTION_SIDECAR,Value=true --region $ECS_TASK_REGION); ACTIVATION_CODE=$(echo $CREATE_ACTIVATION_OUTPUT | jq -e -r .ActivationCode); ACTIVATION_ID=$(echo $CREATE_ACTIVATION_OUTPUT | jq -e -r .ActivationId); if ! amazon-ssm-agent -register -code $ACTIVATION_CODE -id $ACTIVATION_ID -region $ECS_TASK_REGION; then echo \"Failed to register with AWS Systems Manager (SSM), exiting\" 1>&2; exit 1; fi; amazon-ssm-agent & SSM_AGENT_PID=$!; wait $SSM_AGENT_PID; else echo \"ECS Container Metadata not found, exiting\" 1>&2; exit 1; fi; else echo \"SSM agent is already running, exiting\" 1>&2; exit 1; fi"
      ],
      environment = [
        {
          name  = "MANAGED_INSTANCE_ROLE_NAME",
          value = var.ssm_register_instance_role
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.AIOPS_log_group.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "ecs-dev"
        }
      },
      environmentFiles      = [],
      mountPoints           = [],
      volumesFrom           = [],
      secrets               = [],
      dnsServers            = [],
      dnsSearchDomains      = [],
      extraHosts            = [],
      dockerSecurityOptions = [],
      dockerLabels          = {},
      ulimits               = [],
      #logConfiguration = {},
      systemControls = []
  })
}