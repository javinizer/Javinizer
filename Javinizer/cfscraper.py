import cloudscraper
import sys

cookie_value, user_agent = cloudscraper.create_scraper(
    browser={'browser': 'chrome', 'desktop': True}).get_cookie_string(sys.argv[1])
#cookie_value, user_agent = cloudscraper.get_cookie_string(sys.argv[1])

print('{}\n{}'.format(cookie_value, user_agent))
