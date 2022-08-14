terraform {
  cloud {
    organization = "tzk223"
    workspaces {
      name = "twitter-bot"
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
  region = "${var.aws_region}"
}

resource "aws_secretsmanager_secret" "secret_discord_webhook_url" {
  name_prefix = "discord_webhook_url"
}

resource "aws_secretsmanager_secret_version" "secret_version_discord_webhook_url" {
  secret_id     = aws_secretsmanager_secret.secret_discord_webhook_url.id
  secret_string = var.discord_webhook_url
}

resource "aws_secretsmanager_secret" "secret_twitter_bearer_token" {
  name_prefix = "twitter_bearer_token"
}

resource "aws_secretsmanager_secret_version" "secret_version_twitter_bearer_token" {
  secret_id     = aws_secretsmanager_secret.secret_twitter_bearer_token.id
  secret_string = var.twitter_bearer_token
}

resource "aws_ecs_service" "twitter_bot_service" {
  name            = "twitter-bot"
  cluster         = aws_ecs_cluster.twitter_bot_cluster.id
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

resource "aws_cloudwatch_log_group" "twitter_bot_log_group" {
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
    "image": "${var.container_image_name}",
    "cpu": 256,
    "memory": 512,
    "environment": [
      {
        "name": "TWITTER_STREAM_RULES",
        "value": "${var.twitter_stream_rules}"
      }
    ],
    "secrets": [
      {
        "name": "DISCORD_WEBHOOK_URL",
        "valueFrom": "${aws_secretsmanager_secret_version.secret_version_discord_webhook_url.arn}"
      },
      {
        "name": "TWITTER_BEARER_TOKEN",
        "valueFrom": "${aws_secretsmanager_secret_version.secret_version_twitter_bearer_token.arn}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.twitter_bot_log_group.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "twitter-bot"
      }
    },
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

resource "aws_ecs_cluster" "twitter_bot_cluster" {
  name = "twitter_bot_cluster"
}

resource "aws_iam_role_policy" "twitter_bot_get_secret_policy" {
  name = "twitter-bot-get-secret-policy"
  role = "${aws_iam_role.twitter_bot_task_execution_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": [
          "${aws_secretsmanager_secret_version.secret_version_discord_webhook_url.arn}",
          "${aws_secretsmanager_secret_version.secret_version_twitter_bearer_token.arn}"
        ]
    }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test_instance_profile" {
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
  role = "${aws_iam_role.twitter_bot_task_execution_role.name}"
}
