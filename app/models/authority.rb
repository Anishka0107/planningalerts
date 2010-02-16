require 'open-uri'

class Authority < ActiveRecord::Base
  has_many :applications
  named_scope :active, :conditions => 'disabled = 0 or disabled is null'
  
  def self.load_from_web_service(info_logger = logger)
    page = Nokogiri::XML(open(Configuration::INTERNAL_SCRAPERS_INDEX_URL).read)
    page.search('scraper').each do |scraper|
      short_name = scraper.at('authority_short_name').inner_text
      authority = Authority.find_by_short_name(short_name)
      if authority.nil?
        info_logger.info "New authority: #{short_name}"
        authority = Authority.new(:short_name => short_name)
      else
        info_logger.info "Updating authority: #{short_name}"
      end
      authority.full_name = scraper.at('authority_name').inner_text
      authority.feed_url = scraper.at('url').inner_text
      authority.disabled = 0

      authority.save!
    end
  end
  
  def feed_url_for_date(date)
    feed_url.sub("{year}", date.year.to_s).sub("{month}", date.month.to_s).sub("{day}", date.day.to_s)
  end
end
