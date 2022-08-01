"""Custom streaming client class based of tweepy StreamingClient class"""

import logging
import pytz
from tweepy import StreamingClient

class CustomStreamingClient(StreamingClient):
    """Custom streaming client class based of tweepy StreamingClient class"""

    def __init__(self, bearer_token, discord_webhook, tweepy_client):
        """override constructor to include discord webhook and tweepy client attributes"""
        super().__init__(bearer_token)
        self.discord_webhook = discord_webhook
        self.tweepy_client = tweepy_client

    def on_tweet(self, tweet):
        """customize on_tweet action to send message to Discord"""
        logging.info("Getting tweet link from tweet text...")
        logging.debug({ "tweet.text": tweet.text })
        tweet_link = tweet.text.split(" ")[-1]
        logging.debug({ "tweet_link": tweet_link })

        logging.info("Convert tweet timestamp in UTC to string in Pacific Time...")
        logging.debug({ "tweet.created_at": tweet.created_at })
        tweet_datetime_utc = tweet.created_at.replace(tzinfo=pytz.utc)
        logging.debug({ "tweet_datetime_utc": tweet_datetime_utc })
        tweet_datetime_pt = tweet_datetime_utc.astimezone(pytz.timezone("America/Los_Angeles"))
        logging.debug({ "tweet_datetime_pt": tweet_datetime_pt })
        tweet_datetime_pt_string = tweet_datetime_pt.strftime("%Y-%m-%d %H:%M:%S") + " PT"
        logging.debug({ "tweet_datetime_pt_string": tweet_datetime_pt_string })

        logging.info("Getting tweet author username from ID...")
        logging.debug({ "tweet.author_id": tweet.author_id })
        tweet_author_user = self.tweepy_client.get_user(id=tweet.author_id)
        logging.debug({ "tweet_author_user": tweet_author_user })
        tweet_author_username = tweet_author_user[0]["username"]
        logging.debug({ "tweet_author_username": tweet_author_username })

        discord_webhook_username = "twitter-bot"
        discord_webhook_avatar_url = ""
        discord_webhook_content = f"{str(tweet_author_username)} "\
            f"tweeted at {tweet_datetime_pt_string}: {tweet_link}"
        logging.info(
            {
                "discord_webhook_username": discord_webhook_username,
                "discord_webhook_avatar_url": discord_webhook_avatar_url,
                "discord_webhook_content": discord_webhook_content
            }
        )

        logging.info("Sending message with Discord webhook...")
        self.discord_webhook.send(
            username=discord_webhook_username,
            avatar_url=discord_webhook_avatar_url,
            content=discord_webhook_content
        )
