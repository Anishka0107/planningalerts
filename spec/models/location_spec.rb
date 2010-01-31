require File.dirname(__FILE__) + '/../spec_helper'

describe "Location" do
  it "should geocode an address into a latitude and longitude by using the Google service" do
    Geokit::Geocoders::GoogleGeocoder.should_receive(:geocode).with("24 Bruce Road, Glenbrook, NSW 2773").and_return(
      Geokit::LatLng.new(-33.772609, 150.624263))
    Location.geocode("24 Bruce Road, Glenbrook, NSW 2773").should == Location.new(-33.772609, 150.624263)
  end
  
  it "should calculate the coordinates of a square box on the surface of the earth centred on the first point" do
    centre = Location.new(-33.772609, 150.624263)
    result_lower_left, result_upper_right = centre.box_with_size_in_metres(200)
    expected_lower_left = Location.new(-33.773508234721, 150.62309060152)
    expected_upper_right = Location.new(-33.771709765279, 150.62543539848)
    
    # Result should be accurate to within ten metres
    result_lower_left.distance_to(expected_lower_left).should < 10
    result_upper_right.distance_to(expected_upper_right).should < 10
  end
  
  it "should return nil if the address to geocode isn't valid" do
    Geokit::Geocoders::GoogleGeocoder.should_receive(:geocode).with("").and_return(Geokit::LatLng.new(nil, nil))
    Location.geocode("").should == nil
  end
  
  it "should return the country code of the geocoded address" do
    Location.geocode("24 Bruce Road, Glenbrook, NSW 2773").country_code.should == "AU"
  end
end