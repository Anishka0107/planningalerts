PlanningAlerts - a free service which searches as many planning authority websites as it can find and emails
you details of applications near you

Copyright (C) 2009-2013 OpenAustralia Foundation Limited and original contributors to PlanningAlerts.com

The aim of this to enable shared scrutiny of what is being built (and [knocked down](http://www.flickr.com/photos/kentjohnson/3634555801/)) in peoples' communities.

This is the code for the web application side of things written using Ruby on Rails. The original code from PlanningAlerts.com, which this app is based on, was written using php.

This code is free and open-source and is licensed under the GPL v2.

PlanningAlerts is brought to you by the [OpenAustralia Foundation](http://www.openaustraliafoundation.org.au). It was adapted for Australia by Matthew Landauer and Katherine Szuminska, and is based on the UK site [PlanningAlerts.com](http://www.planningalerts.com), built by Richard Pope, Mikel Maron, Sam Smith, Duncan Parkes, Tom Hughes and Andy Armstrong.

### Setting up a dev environment [![Build Status](https://travis-ci.org/openaustralia/planningalerts-app.png?branch=master)](https://travis-ci.org/openaustralia/planningalerts-app) [![Dependency Status](https://gemnasium.com/openaustralia/planningalerts-app.png)](https://gemnasium.com/openaustralia/planningalerts-app) [![Coverage Status](https://coveralls.io/repos/openaustralia/planningalerts-app/badge.png?branch=master)](https://coveralls.io/r/openaustralia/planningalerts-app?branch=master) [![Code Climate](https://codeclimate.com/github/openaustralia/planningalerts-app.png)](https://codeclimate.com/github/openaustralia/planningalerts-app)

**Install Dependencies**
 * Install MySql - On OSX download dmg from [http://dev.mysql.com/downloads/](http://dev.mysql.com/downloads/)
 * Install Sphinx - `brew install sphinx`

**Checkout The Project**
 * Fork the project on Github
 * Checkout the project

**Install Ruby Dependencies**
 * Install bundler - `gem install bundler`
 * Install dependencies - `bundle install`

**Setup The Database**
 * Create your own database config file - `cp config/database.yml.example config/database.yml`
 * Update the config/database.yml with your root mysql credentials
 * If you are on OSX change the socket to /tmp/mysql.sock
 * Create the databases - `rake db:create`
 * Load the database schema - `rake db:schema:load`

**Run The Tests**
 * Run the test suite - `rake`

#### Scraping and sending emails in your dev environment

**Step 1 - Seed authorities table**
 * Change `INTERNAL_SCRAPERS_INDEX_URL` in app/models/configuration.rb to point to : http://www.planningalerts.org.au/scrapers/
 * Load the authorities - `rake planningalerts:authorities:load`

**Step 2 - Scrape DAs**
 * Run - `rake planningalerts:applications:scrape['marrickville']`

**Step 3 - Setup an Alert**
 * Start the rails server - `rails s`
 * Start MailCatcher - `mailcatcher`
 * Hit the home page - http://localhost:3000
 * Enter an address e.g. 638 King St, Newtown NSW 2042
 * Click the "Email me" link and setup an alert
 * Open MailCatcher and click the confirm link: http://localhost:1080/

**Step 4 - Send email alerts**
 * Run - `rake planningalerts:applications:email`
 * Check the email in your browser: http://localhost:1080/
 * To resend alerts during testing, just set the `last_sent` attribute of your alert to *nil*

### Contact

You can get in touch at [contact@planningalerts.org.au](mailto:contact@planningalerts.org.au)
