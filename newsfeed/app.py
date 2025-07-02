from api import create_app
from api.newsfeed import Newsfeed

import os

valid_tokens = [os.getenv("NEWSFEED_SERVICE_TOKEN", "default_token_if_not_set")]
feed_urls = [
    "https://www.martinfowler.com/feed.atom",
    "https://www.reddit.com/r/sysadmin/.rss",
]

app = create_app(valid_tokens, Newsfeed(feed_urls))
