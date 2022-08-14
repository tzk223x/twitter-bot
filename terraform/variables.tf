variable "aws_region" {
  default = "us-west-2"
  type = string
}

variable "aws_access_key_id" {
  type = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type = string
  sensitive = true
}

variable "discord_webhook_avatar_url" {
  type = string
}

variable "discord_webhook_url" {
  type = string
  sensitive = true
}

variable "discord_webhook_username" {
  type = string
}

variable "twitter_bearer_token" {
  type = string
  sensitive = true
}

variable "twitter_stream_rules" {
  type = string
}

variable "container_image_name" {
  type = string
}
