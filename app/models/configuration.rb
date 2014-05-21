# Stores application configuration settings
module Configuration
  # URL Stuff
  HOST = 'localhost:3000'

  # See https://morph.io/api
  MORPH_API_KEY = "xxxxxxxxxxxxxxxxxxxx"

  # Email setup
  EMAIL_FROM_ADDRESS = 'contact@planningalerts.org.au'
  EMAIL_FROM_NAME = 'PlanningAlerts'
  # Email that bounced emails go to (sets Return-Path header in outgoing email)
  BOUNCE_EMAIL_ADDRESS = EMAIL_FROM_ADDRESS
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

  # Google Analytics key
  GOOGLE_ANALYTICS_KEY = "UA-3107958-5"

  # Values used in the API examples
  API_EXAMPLE_ADDRESS = "24 Bruce Road Glenbrook, NSW 2773"
  API_EXAMPLE_SIZE = 4000
  API_EXAMPLE_AUTHORITY = "blue_mountains"
  API_EXAMPLE_POSTCODE = "2780"
  API_EXAMPLE_SUBURB = "Katoomba"
  API_EXAMPLE_STATE = "NSW"

  # This lat/lng is for 24 Bruce Road as well
  API_EXAMPLE_LAT = -33.772609
  API_EXAMPLE_LNG = 150.624263

  # This covers most of Victoria and NSW
  API_EXAMPLE_BOTTOM_LEFT_LAT = -38.556757
  API_EXAMPLE_BOTTOM_LEFT_LNG = 140.833740
  API_EXAMPLE_TOP_RIGHT_LAT = -29.113775
  API_EXAMPLE_TOP_RIGHT_LNG = 153.325195

  # OAuth details for Twitter application with read access only (for twitter feed on home page)
  TWITTER_CONSUMER_KEY = "xxxxxxxxxxx"
  TWITTER_CONSUMER_SECRET = "xxxxxxxxxxx"
  TWITTER_OAUTH_TOKEN = "xxxxxxxxxxx"
  TWITTER_OAUTH_TOKEN_SECRET = "xxxxxxxxxxx"

  # Configuration for the theme
  THEME_NSW_HOST = "nsw.127.0.0.1.xip.io:3000"
  THEME_NSW_EMAIL_FROM_ADDRESS = "contact@nsw.127.0.0.1.xip.io"
  THEME_NSW_EMAIL_FROM_NAME = "NSW PlanningAlerts"
end
