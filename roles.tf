# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution roleg
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
  tags = {
    Environment = "AIOPS"
    Project     = "POC"
  }
}

/*# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/ecsTaskExecutionRole"
  #policy_arn = "arn:aws:iam::471112971975:role/ecsTaskExecutionRole"
}*/

# Attach the first policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy1" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# Attach the second policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy2" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}
# Attach the third policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy3" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForServiceConnectTransportLayerSecurity"

}

# Attach the fourth policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy4" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes"

}

/** ====================================================
* Create ECS task Role
* ==================================================== **/
# ECS task role data
data "aws_iam_policy_document" "ecs_task_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [471112971975]
    }
  }
}

# ECS task role
resource "aws_iam_role" "ecs_task_role" {
  name               = var.ecs_task_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
  tags = {
    Environment = "AIOPS"
    Project     = "POC"
  }
}

resource "aws_iam_role_policy" "ecs_ssm_policy" {
  name = var.ecs_ssm_policy
  role = aws_iam_role.ecs_task_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:CreateActivation",
          "ssm:AddTagsToResource",
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}



/** ====================================================
* Create SSM Register Instance Role
* ==================================================== **/

# SSM Register Instance data
data "aws_iam_policy_document" "ssm_register_instance_assume" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

#Create a Role for registering an instance
resource "aws_iam_role" "ssm_register_instance" {
  name               = var.ssm_register_instance_role
  assume_role_policy = data.aws_iam_policy_document.ssm_register_instance_assume.json
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_policy" {
  role       = aws_iam_role.ssm_register_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ecs_ssm_deregister_policy" {
  name = var.ecs_ssm_deregister_policy
  role = aws_iam_role.ssm_register_instance.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:DeleteActivation",
          "ssm:DeregisterManagedInstance"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}