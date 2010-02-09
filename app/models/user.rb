class User < ActiveRecord::Base
  set_table_name :user
  set_primary_key :user_id

  validates_numericality_of :area_size_meters, :greater_than => 0, :message => "isn't selected"
  validate :validate_email, :validate_address
  
  before_validation :geocode
  before_create :set_confirm_info
  before_create :remove_other_alerts_for_this_address
  
  def location=(l)
    if l
      self.lat = l.lat
      self.lng = l.lng
    end
  end
  
  def location
    Location.new(lat, lng) if lat && lng
  end
  
  def search_area
    Area.centre_and_size(location, area_size_meters)
  end
  
  # Applications that have been scraped since the last time the user was sent an alert
  def recent_applications
    Application.within(search_area).find(:all, :conditions => ['date_scraped > ?', last_sent || Date.yesterday])
  end
  
  # This is a long-running method. Call with care
  # TODO: Untested method
  def self.send_alerts(info_logger = logger)
    # Only send alerts to confirmed users
    no_emails = 0
    no_applications = 0
    users = User.find_all_by_confirmed(true)
    info_logger.info "Checking #{users.count} confirmed users"
    users.each do |user|
      applications = user.recent_applications
      no_applications += applications.size
      unless applications.empty?
        UserNotifier.deliver_alert(user, applications)
        no_emails += 1
      end
    end
    info_logger.info "Sent #{no_applications} applications to #{no_emails} people!"
  end
  
  private
  
  def remove_other_alerts_for_this_address
    User.delete_all(:email => email, :address => address)
  end
  
  def set_confirm_info
    # TODO: Should check that this is unique across all alerts and if not try again
    self.confirm_id = Digest::MD5.hexdigest(rand.to_s + Time.now.to_s)[0...20]
  end

  def geocode
    # Only geocode if location hasn't been set
    if self.lat.nil? && self.lng.nil?
      @geocode_result = Location.geocode(address)
      self.location = @geocode_result
      self.address = @geocode_result.full_address
    end
  end
  
  def validate_address
    # Only validate the street address if we used the geocoder
    if @geocode_result
      if address == ""
        errors.add(:street_address, "can't be empty")
      elsif location.nil?
        errors.add(:street_address, "isn't valid")
      elsif @geocode_result.country_code != "AU"
        errors.add(:street_address, "isn't in Australia")
      elsif @geocode_result.all.size > 1
        errors.add(:street_address, "isn't complete. Please enter a full street address, including suburb and state, e.g. #{@geocode_result.full_address}")
      elsif @geocode_result.accuracy < 6
        errors.add(:street_address, "isn't complete. We saw that address as \"#{@geocode_result.full_address}\" which we don't recognise as a full street address. Check your spelling and make sure to include suburb and state")
      end
    end
  end
  
  def validate_email
    if email == ""
      errors.add(:email_address, "can't be empty")
    else
      begin
        TMail::Address.parse(email)
      rescue
        errors.add(:email_address, "isn't valid")
      end
    end
  end
end
