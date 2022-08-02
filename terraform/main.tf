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

resource "aws_ecr_repository" "ecr_repository" {
  name                 = "bar"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_task_definition" "test" {
  family                   = "test"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "hello-world",
    "image": "registry.hub.docker.com/tzk223/twitter-bot:latest",
    "cpu": 256,
    "memory": 512,
    "environment": {
      "DISCORD_WEBHOOK_URL": "${var.discord_webhook_url}",
      "TWITTER_BEARER_TOKEN": "${var.twitter_bearer_token}"
    },
    "essential": true
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
