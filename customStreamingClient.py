from discord import Webhook, RequestsWebhookAdapter
import pytz
from tweepy import StreamingClient

class CustomStreamingClient(StreamingClient):
    def __init__(self, bearer_token, webhook_url, tweepy_client):
        super().__init__(bearer_token)
        self.webhook_url = webhook_url
        self.tweepy_client = tweepy_client

    def on_tweet(self, tweet):
        # Get tweet link from tweet text
        tweet_link = tweet.text.split(" ")[-1]

        # Convert tweet timestamp to Pacific Time
        tweet_datetime_utc = tweet.created_at.replace(tzinfo=pytz.utc)
        tweet_datetime_pt = tweet_datetime_utc.astimezone(pytz.timezone("America/Los_Angeles"))
        tweet_datetime_pt_string = tweet_datetime_pt.strftime("%Y-%m-%d %H:%M:%S") + " PT"
        
        # Get tweet author username from ID
        tweet_author_user = self.tweepy_client.get_user(id=tweet.author_id)
        tweet_author_username = tweet_author_user[0]["username"]

        # Create webhook
        webhook = Webhook.from_url(self.webhook_url, adapter=RequestsWebhookAdapter())
        webhook_username = "twitter-bot"
        webhook_avatar_url = ""
        webhook_content = f"{str(tweet_author_username)} tweeted at {tweet_datetime_pt_string}: {tweet_link}"
        print([webhook_username,webhook_avatar_url,webhook_content])
        webhook.send(username=webhook_username, avatar_url=webhook_avatar_url, content=webhook_content)
