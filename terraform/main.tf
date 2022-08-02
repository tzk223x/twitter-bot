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

resource "aws_ecs_task_definition" "aws_ecs_task_definition_01" {
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
}
