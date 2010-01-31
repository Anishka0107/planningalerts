# Super thin veneer over Geokit geocoder and the results of the geocoding. The other main difference with
# geokit vanilla is that the distances are all in meters and the geocoding is biased towards Australian addresses

class Location < SimpleDelegator
  def initialize(*params)
    if params.count == 2
      super(Geokit::LatLng.new(*params))
    elsif params.count == 1
      super(params.first)
    else
      raise "Unexpected number of parameters"
    end
  end

  def self.geocode(address)
    Location.new(Geokit::Geocoders::GoogleGeocoder.geocode(address, :bias => "au"))
  end
  
  # Coordinates of bottom-left and top-right corners of a box centred on the current location
  # with a given size in metres
  def box_with_size_in_metres(size_in_metres)
    lower_center = endpoint(180, size_in_metres / 2)
    upper_center = endpoint(0, size_in_metres / 2)
    center_left = endpoint(270, size_in_metres / 2)
    center_right = endpoint(90, size_in_metres / 2)
    lower_left = Location.new(lower_center.lat, center_left.lng)
    upper_right = Location.new(upper_center.lat, center_right.lng)
    [lower_left, upper_right]
  end
  
  # Distance given is in metres
  def endpoint(bearing, distance)
    Location.new(__getobj__.endpoint(bearing, distance / 1000.0, :units => :kms))
  end
  
  # Distance (in metres) to other point
  def distance_to(l)
    __getobj__.distance_to(l.__getobj__, :units => :kms) * 1000.0
  end
end