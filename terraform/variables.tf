variable "discord_webhook_url" {
  type = string
  sensitive = true
}

variable "twitter_bearer_token" {
  type = string
  sensitive = true
}

variable "container_image" {
  type = string
  sensitive = true
}