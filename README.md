# twitter-bot

A Twitter bot that sends a message to a Discord webhook when it receives a filtered tweet.

## Local Development

### Run Application Locally

1. Create a file called .env at root of project with desired environment variables

```
#.env

DISCORD_WEBHOOK_AVATAR_URL="https://pbs.twimg.com/profile_images/1493013357057933312/K31_DCl-_400x400.jpg"
DISCORD_WEBHOOK_URL=""
DISCORD_WEBHOOK_USERNAME="twitter-bot"
TWITTER_BEARER_TOKEN=""
TWITTER_STREAM_RULES="genshin -is:retweet -is:reply has:media"
```

1. Run app/run.py with Python 3

```bash
cd ./app
python3 run.py
```

### Deploy Infrastructure Locally

1. Set the following local variables

```bash
export TF_VAR_aws_access_key_id=""
export TF_VAR_aws_secret_access_key=""
export TF_VAR_discord_webhook_avatar_url="https://pbs.twimg.com/profile_images/1493013357057933312/K31_DCl-_400x400.jpg"
export TF_VAR_discord_webhook_url=""
export TF_VAR_discord_webhook_username="twitter-bot"
export TF_VAR_container_image_name="tzk223/twitter-bot:latest"
export TF_VAR_twitter_bearer_token=""
export TF_VAR_twitter_stream_rules="genshin -is:retweet -is:reply has:media"
```

1. Change to terraform directory and run terraform command

```bash
cd ./terraform
terraform plan
```

## Using GitHub Workflow

### Secrets

A list of secrets needed to build and deploy:

| Secret Name | Description |
| --- | --- |
| AWS_ACCESS_KEY_ID | AWS access key ID for programmatic access to AWS account (<https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html>) |
| AWS_SECRET_ACCESS_KEY | AWS secret access key for programmatic access to AWS account (<https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html>) |
| DISCORD WEBHOOK_AVATAR_URL | URL to image to be used as the avatar for the Discord webhook |
| DISCORD_WEBHOOK_URL | Discord webhook URL for target Discord channel for message to be sent (<https://discord.com/developers/docs/resources/webhook>) |
| DISCORD_WEBHOOK_URL | Username to use used in for the Discord webhook |
| DOCKER_HUB_PERSONAL_ACCESS_TOKEN | Docker Hub personal access token to publish application container (<https://docs.docker.com/docker-hub/access-tokens/>) |
| TF_API_TOKEN | Terraform Cloud API token (<https://www.terraform.io/cloud-docs/users-teams-organizations/api-tokens>) |
| TWITTER_BEARER_TOKEN | Twitter bearer token to access Twitter API (<https://developer.twitter.com/en/docs/authentication/oauth-2-0/bearer-tokens>) |
| TWITTER_STREAM_RULES | Comma separated strings of twitter filtered stream rules (<https://developer.twitter.com/en/docs/twitter-api/tweets/filtered-stream/integrate/build-a-rule>) |

## Use of Twitter Stream Rules

- Production

```
from:GenshinImpact -is:retweet -is:reply
```

- Development

```
genshin -is:retweet -is:reply has:media
```