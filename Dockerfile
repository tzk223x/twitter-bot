FROM registry.hub.docker.com/library/python:3-slim

ENV DISCORD_WEBHOOK_URL TWITTER_BEARER_TOKEN TWITTER_STREAM_RULES

WORKDIR /usr/src/app

COPY ./app ./
RUN pip3 install --no-cache-dir -r requirements.txt

CMD [ "python3", "./run.py" ]