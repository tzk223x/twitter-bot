variable "discord_webhook_url" {
  type = string
  sensitive = true
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

variable "aws_region" {
  default = "us-west-2"
  type = string
}