# Stores application configuration settings
module Configuration
  # Email setup
  EMAIL_FROM_ADDRESS = 'contact@planningalerts.org.au'
  EMAIL_FROM_NAME = 'PlanningAlerts'
  # The email that abuse reports are sent to
  EMAIL_MODERATOR = EMAIL_FROM_ADDRESS

  # Scraper params
  SCRAPE_DELAY = 5

  # Google maps key
  # Use the following maps API key if you are running your development instance at http://planningalerts-app.dev
  # This will be the case if you are using pow (http://pow.cx/)
  GOOGLE_MAPS_KEY = 'ABQIAAAAo-lZBjwKTxZxJsD-PJnp8RTctXwaglzRZcFAUhNsPfHMAK74xRSSE3HhjcyVtlJHXKjyRyk_3L4CYA'

  # If you have Google Maps API for Business (OpenAustralia Foundation gets it through the Google Maps API
  # grants programme for charities) uncomment and fill out the two lines below
  #GOOGLE_MAPS_CLIENT_ID = "xxxxxxxxxxx"
  #GOOGLE_MAPS_CRYPTOGRAPHIC_KEY = "xxxxxxxxxxx"

  # OAuth details for Twitter application with read access only (for twitter feed on home page)
  # TWITTER_CONSUMER_KEY = "xxxxxxxxxxx"
  # TWITTER_CONSUMER_SECRET = "xxxxxxxxxxx"
  # TWITTER_OAUTH_TOKEN = "xxxxxxxxxxx"
  # TWITTER_OAUTH_TOKEN_SECRET = "xxxxxxxxxxx"

  # cuttlefish.io is used to send out emails in production
  CUTTLEFISH_SERVER = "cuttlefish.io"
  CUTTLEFISH_USER_NAME = "xxxxxxxxxxxxxxxxx"
  CUTTLEFISH_PASSWORD = "xxxxxxxxxxxxxxxxxxxx"

  # Configuration for the theme
  THEME_NSW_HOST = "nsw.127.0.0.1.xip.io:3000"
  THEME_NSW_EMAIL_FROM_ADDRESS = "contact@nsw.127.0.0.1.xip.io"
  THEME_NSW_EMAIL_FROM_NAME = "Application Tracking"

  THEME_NSW_CUTTLEFISH_USER_NAME = "xxxxxxxxxxxxxxxxx"
  THEME_NSW_CUTTLEFISH_PASSWORD = "xxxxxxxxxxxxxxxxxxxx"

  THEME_NSW_GOOGLE_ANALYTICS_KEY = "UA-3107958-12"

  HONEYBADGER_API_KEY = 'xxxxxxxx'

  # Stripe is used to process cards and customers
  # for subscriptions. See app/controllers/subscriptions_controller.rb
  STRIPE_PUBLISHABLE_KEY = 'xxxxxxxxxxxxxxxxx'
  STRIPE_SECRET_KEY = 'xxxxxxxxxxxxxxxxx'

  DEVISE_SECRET_KEY = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  SECRET_KEY_BASE = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # It can be useful to temporarily stops API calls being logged
  DISABLE_API_LOGGING = false
end
