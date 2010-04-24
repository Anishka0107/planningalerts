module ApiHowtoHelper
  # Turn a url for an arbitrary georss feed into a Google Map of that data
  def mapify(url, zoom = 13)
      "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=#{zoom}&om=1&q=#{CGI.escape(url)}"
  end
  
  def htmlify(url)
    url.gsub(/(\?|&|&amp;)([a-z_]+)=/, '\1<strong>\2</strong>=')
  end
  
  def api_example_address_url(address = Configuration::API_EXAMPLE_ADDRESS,
    area_size = Configuration::API_EXAMPLE_SIZE)
    applications_url(:format => "rss", :address => address, :radius => area_size)
  end
  
  def api_example_latlong_url(lat = Configuration::API_EXAMPLE_LAT, lng = Configuration::API_EXAMPLE_LNG, 
    area_size = Configuration::API_EXAMPLE_SIZE)
    applications_url(:format => "rss", :lat => lat, :lng => lng, :radius => area_size)
  end
  
  def api_example_area_url(bottom_left_lat = Configuration::API_EXAMPLE_BOTTOM_LEFT_LAT,
    bottom_left_lng = Configuration::API_EXAMPLE_BOTTOM_LEFT_LNG,
    top_right_lat = Configuration::API_EXAMPLE_TOP_RIGHT_LAT,
    top_right_lng = Configuration::API_EXAMPLE_TOP_RIGHT_LNG)
    applications_url(:format => "rss",
      :bottom_left_lat => bottom_left_lat, :bottom_left_lng => bottom_left_lng,
      :top_right_lat => top_right_lat, :top_right_lng => top_right_lng)
  end
  
  def api_example_authority_url(authority = Configuration::API_EXAMPLE_AUTHORITY)
    authority_applications_url(:format => "rss", :authority_id => authority)
  end
  
  def api_example_postcode_url(postcode = Configuration::API_EXAMPLE_POSTCODE)
    applications_url(:format => "rss", :postcode => postcode)
  end
  
  def api_example_suburb_and_state_url(suburb = Configuration::API_EXAMPLE_SUBURB, state = Configuration::API_EXAMPLE_STATE)
    applications_url(:format => "rss", :suburb => suburb, :state => state)
  end
  
  def api_example_address_url_html
    # Doing this hackery with 11's and 22's so that we don't escape "[" and "]"
    htmlify(api_example_address_url("11", "22").sub("11", "[address]").sub("22", "[distance_in_metres]"))
  end
  
  def api_example_latlong_url_html
    htmlify(api_example_latlong_url("11", "22", "33").sub("11", "[latitude]").sub("22", "[longitude]").sub("33", "[distance_in_metres]"))
  end
  
  def api_example_area_url_html
    htmlify(api_example_area_url("11", "22", "11", "22").gsub("11", "[latitude]").gsub("22", "[longitude]"))
  end
  
  def api_example_authority_url_html
    htmlify(api_example_authority_url("11").sub("11", "[name]"))
  end

  def api_example_postcode_url_html
    htmlify(api_example_postcode_url("11").sub("11", "[postcode]"))
  end

  def api_example_suburb_and_state_url_html
    htmlify(api_example_suburb_and_state_url("11", "22").sub("11", "[suburb]").sub("22", "[state]"))
  end
end
