from customStreamingClient import CustomStreamingClient
import dotenv
import tweepy
import os
from dotenv import load_dotenv

load_dotenv()

DISCORD_WEBHOOK_URL = os.getenv('DISCORD_WEBHOOK_URL')
TWITTER_BEARER_TOKEN = os.getenv('TWITTER_BEARER_TOKEN')

def main():
    # Create tweepy streaming client
    tweepy_client = tweepy.Client(TWITTER_BEARER_TOKEN)
    tweepy_streaming_client = CustomStreamingClient(TWITTER_BEARER_TOKEN, DISCORD_WEBHOOK_URL, tweepy_client)
    
    # Clear all rules attached to account and add desired rules
    rules = tweepy_streaming_client.get_rules()
    if rules[0]:
        for rule in rules[0]:
            tweepy_streaming_client.delete_rules(rule.id)
    #rule = tweepy.StreamRule(value="from:GenshinImpact -is:retweet")
    rule = tweepy.StreamRule(value="genshin -is:retweet -is:reply has:media")
    tweepy_streaming_client.add_rules(rule)
    print(["Filter Rules: ",rules])

    # Start tweepy streaming client
    tweepy_streaming_client.filter(tweet_fields=["created_at"], expansions="author_id")

main()
