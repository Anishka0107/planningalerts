require 'open-uri'

class Application < ActiveRecord::Base
  belongs_to :authority
  before_save :lookup_comment_tinyurl, :lookup_info_tinyurl, :geocode
  
  named_scope :within, lambda { |a|
    { :conditions => ['lat > ? AND lng > ? AND lat < ? AND lng < ?', a.lower_left.lat, a.lower_left.lng, a.upper_right.lat, a.upper_right.lng] }
  }
  
  # TODO: factor out common location accessor between Application and Alert
  def location
    Location.new(lat, lng) if lat && lng
  end
  
  # Optionally pass a logger which is just used for sending informational messages to do with this long-running job to
  def self.collect_applications(info_logger = logger)
    start_date = Date.today - Configuration::SCRAPE_DELAY
    # Go through the dates in reverse chronological order
    (start_date..(Date.today)).to_a.reverse.each do |date|
      authorities = Authority.active
      info_logger.info "Scraping #{authorities.count} authorities"
      authorities.each do |auth|
        collect_applications_for_authority(auth, date, info_logger)
      end
    end
  end
  
  def self.collect_applications_for_authority(auth, date, info_logger = logger)
    url = auth.feed_url_for_date(date)
    info_logger.info "Scraping authority #{auth.full_name} from #{url}"
    begin
      feed_data = open(url).read
    rescue Exception => e
      info_logger.error "Error #{e} while getting data from url #{url}. So, skipping"
      return
    end
    feed = Nokogiri::XML(feed_data)
    applications = feed.search('application')
    info_logger.info "Found #{applications.count} applications for #{auth.full_name}"
    
    applications.each do |a|
      council_reference = a.at('council_reference').inner_text
      # TODO Consider if it would be better to overwrite applications with new data if they already exists
      # This would allow for the possibility that the application information was incorrectly entered at source
      # and was updated. But we would have to think whether those updated applications should get mailed out, etc...
      if auth.applications.find_by_council_reference(council_reference)
        info_logger.info "Application already exists in database #{council_reference}"
      else
        auth.applications.create!(
          :council_reference => council_reference,
          :address => a.at('address').inner_text,
          :description => a.at('description').inner_text,
          :info_url => a.at('info_url').inner_text,
          :comment_url => a.at('comment_url').inner_text,
          # TODO date_recieved attribute is misspelled!
          :date_recieved => a.at('date_received').inner_text,
          :date_scraped => DateTime.now)
        info_logger.info "Saving application #{council_reference}"
      end
    end
  end
  
  # TODO: This is very similar to the method in the api_howto_helper. Maybe they should be together?
  def map_url
    zoom = 15
    "http://maps.google.com/maps?q=#{CGI.escape(address)}&z=#{zoom}";
  end

  private
  
  # Very thin wrapper around ShortURL gem
  def self.shorten_url(url)
    if url
      ShortURL.shorten(url, :tinyurl)
    else
      logger.warn "shortening of url was skipped for application number: #{id} because url is empty"
      nil
    end
  end
  
  def lookup_comment_tinyurl
    self.comment_tinyurl = Application.shorten_url(comment_url)
  end
  
  def lookup_info_tinyurl
    self.info_tinyurl = Application.shorten_url(info_url)
  end
  
  # TODO: Optimisation is to make sure that this doesn't get called again on save when the address hasn't changed
  def geocode
    # Only geocode if location hasn't been set
    if self.lat.nil? || self.lng.nil? || self.suburb.nil? || self.state.nil? || self.postcode.nil?
      r = Location.geocode(address)
      if r.success
        self.lat = r.lat
        self.lng = r.lng
        self.suburb = r.suburb
        self.state = r.state
        self.postcode = r.postcode
      else
        logger.error "Couldn't geocode address: #{address}"
      end
    end
  end
end
