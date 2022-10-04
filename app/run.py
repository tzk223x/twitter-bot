"""Entry point to run Twitter bot"""

import argparse
import logging
import os
from discord import Webhook, RequestsWebhookAdapter
from dotenv import load_dotenv
import tweepy
from custom_streaming_client import CustomStreamingClient

# Importing arguments
parser = argparse.ArgumentParser(
    description="Runs Twitter bot",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter
)
parser.add_argument(
    "--discord-webhook-avatar-url",
    help="Discord webhook avatar URL",
    type=str
)
parser.add_argument(
    "--discord-webhook-url",
    help="Discord webhook URL",
    type=str
)
parser.add_argument(
    "--discord-webhook-username",
    help="Discord webhook username",
    type=str
)
parser.add_argument(
    "--twitter-bearer-token",
    help="Twitter API bearer token",
    type=str
)
parser.add_argument(
    "--twitter-stream-rules",
    help="Twitter filtered stream rules",
    type=str
)
parser.add_argument(
    "--debug",
    action="store_true",
    help="Set logging level to DEBUG"
)
args=parser.parse_args()

# Create logger
logger = logging.getLogger()
logger.setLevel(logging.NOTSET)

# Create console logger
CONSOLE_HANDLER_FORMAT = '%(asctime)s | %(levelname)s: %(message)s'
console_handler = logging.StreamHandler()
if args.debug:
    console_handler.setLevel(logging.DEBUG)
else:
    console_handler.setLevel(logging.INFO)
console_handler.setFormatter(logging.Formatter(CONSOLE_HANDLER_FORMAT))
logger.addHandler(console_handler)

load_dotenv()

if args.discord_webhook_avatar_url:
    DISCORD_WEBHOOK_AVATAR_URL = args.discord_webhook_avatar_url
else:
    DISCORD_WEBHOOK_AVATAR_URL = os.getenv('DISCORD_WEBHOOK_AVATAR_URL')

if args.discord_webhook_url:
    DISCORD_WEBHOOK_URL = args.discord_webhook_url
else:
    DISCORD_WEBHOOK_URL = os.getenv('DISCORD_WEBHOOK_URL')

if args.discord_webhook_url:
    DISCORD_WEBHOOK_USERNAME = args.discord_webhook_username
else:
    DISCORD_WEBHOOK_USERNAME = os.getenv('DISCORD_WEBHOOK_USERNAME')

if args.twitter_bearer_token:
    TWITTER_BEARER_TOKEN = args.twitter_bearer_token
else:
    TWITTER_BEARER_TOKEN = os.getenv('TWITTER_BEARER_TOKEN')

if args.twitter_stream_rules:
    TWITTER_STREAM_RULES = args.twitter_stream_rules
else:
    TWITTER_STREAM_RULES = os.getenv('TWITTER_STREAM_RULES')

def main(discord_webhook_avatar_url, discord_webhook_url, discord_webhook_username, twitter_bearer_token, twitter_stream_rules):
    """Main routine"""

    logging.info("Creating Discord webhook...")
    discord_webhook = Webhook.from_url(discord_webhook_url, adapter=RequestsWebhookAdapter())

    logging.info("Creating Tweepy streaming client...")
    tweepy_client = tweepy.Client(twitter_bearer_token)
    tweepy_streaming_client = CustomStreamingClient(twitter_bearer_token,
        discord_webhook, discord_webhook_avatar_url, discord_webhook_username, tweepy_client)

    logging.info("Clearing all rules attached to account...")
    rules = tweepy_streaming_client.get_rules()
    logging.debug({ "rules": rules })
    if rules[0]:
        for rule in rules[0]:
            tweepy_streaming_client.delete_rules(rule.id)

    logging.info("Adding desired rules...")
    rules = []
    twitter_stream_rules_array = twitter_stream_rules.split(",")
    for twitter_stream_rule in twitter_stream_rules_array:
        logging.info({"Stream rule": twitter_stream_rule})
        rule = tweepy.StreamRule(value=twitter_stream_rule)
        rules.append(rule)
    tweepy_streaming_client.add_rules(rules)
    rules = tweepy_streaming_client.get_rules()
    logging.debug({ "rules": rules })

    logging.info("Starting Tweepy streaming client...")
    tweepy_streaming_client.filter(tweet_fields=["created_at"], expansions="author_id")

if __name__ == "__main__":
    main(DISCORD_WEBHOOK_AVATAR_URL, DISCORD_WEBHOOK_URL, DISCORD_WEBHOOK_USERNAME, TWITTER_BEARER_TOKEN, TWITTER_STREAM_RULES)
