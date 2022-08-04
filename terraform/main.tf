terraform {
  cloud {
    organization = "tzk223"
    workspaces {
      name = "Example-Workspace"
    }
  }
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_ecr_repository" "aws_ecr_repository_01" {
  name                 = "repo"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_service" "twitter_bot" {
  name            = "twitter-bot"
  cluster         = aws_ecs_cluster.app.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.twitter_bot.arn
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress_all.id,
      aws_security_group.no_ingress.id,
    ]

    subnets = [
      aws_subnet.private_c.id,
      aws_subnet.private_d.id,
    ]
  }
}

resource "aws_cloudwatch_log_group" "twitter_bot" {
  name = "/ecs/twitter-bot"
}


resource "aws_ecs_task_definition" "twitter_bot" {
  family                   = "twitter-bot"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "twitter-bot",
    "image": "registry.hub.docker.com/tzk223/twitter-bot:latest",
    "cpu": 256,
    "memory": 512,
    "environment": [
      {
        "name": "DISCORD_WEBHOOK_URL",
        "value": "${var.discord_webhook_url}"
      },
      {
        "name": "TWITTER_BEARER_TOKEN",
        "value": "${var.twitter_bearer_token}"
      }
    ],
    "essential": true
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  execution_role_arn = aws_iam_role.twitter_bot_task_execution_role.arn
}

resource "aws_iam_role" "twitter_bot_task_execution_role" {
  name               = "twitter-bot-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.twitter_bot_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_ecs_cluster" "app" {
  name = "app"
}