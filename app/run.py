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
    "--discord-webhook-url",
    help="Discord webhook URL",
    type=str
)
parser.add_argument(
    "--twitter-bearer-token",
    help="Twitter API bearer token",
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

if args.discord_webhook_url:
    DISCORD_WEBHOOL_URL = args.discord_webhook_url
else:
    DISCORD_WEBHOOL_URL = os.getenv('DISCORD_WEBHOOK_URL')

if args.twitter_bearer_token:
    TWITTER_BEARER_TOKEN = args.twitter_bearer_token
else:
    TWITTER_BEARER_TOKEN = os.getenv('TWITTER_BEARER_TOKEN')

def main(discord_webhook_url, twitter_bearer_token, stream_rule_values):
    """Main routine"""

    logging.info("Creating Discord webhook...")
    discord_webhook = Webhook.from_url(discord_webhook_url, adapter=RequestsWebhookAdapter())

    logging.info("Creating Tweepy streaming client...")
    tweepy_client = tweepy.Client(twitter_bearer_token)
    tweepy_streaming_client = CustomStreamingClient(twitter_bearer_token,
        discord_webhook, tweepy_client)

    logging.info("Clearing all rules attached to account...")
    rules = tweepy_streaming_client.get_rules()
    logging.debug({ "rules": rules })
    if rules[0]:
        for rule in rules[0]:
            tweepy_streaming_client.delete_rules(rule.id)

    logging.info("Adding desired rules...")
    rules = []
    for stream_rule_value in stream_rule_values:
        rule = tweepy.StreamRule(value=stream_rule_value)
        rules.append(rule)
    tweepy_streaming_client.add_rules(rules)
    rules = tweepy_streaming_client.get_rules()
    logging.debug({ "rules": rules })

    logging.info("Starting Tweepy streaming client...")
    tweepy_streaming_client.filter(tweet_fields=["created_at"], expansions="author_id")

if __name__ == "__main__":
    #STREAM_RULE_VALUES=["genshin -is:retweet -is:reply has:media"]
    STREAM_RULE_VALUES=["from:GenshinImpact -is:retweet -is:reply"]
    main(DISCORD_WEBHOOL_URL, TWITTER_BEARER_TOKEN, STREAM_RULE_VALUES)
