require 'spec_helper'

describe User do
  before :each do
    @address = "24 Bruce Road, Glenbrook, NSW"
    @attributes = {:email => "matthew@openaustralia.org", :address => @address,
      :area_size_meters => 200}
    # Unless we override this elsewhere just stub the geocoder to return some arbitrary coordinates notionally in Australia
    @loc = Location.new(1.0, 2.0)
    @loc.stub!(:country_code).and_return("AU")
    @loc.stub!(:all).and_return([@loc])
    Location.stub!(:geocode).and_return(@loc)
  end

  it "should have no trouble creating a user with valid attributes" do
    User.create!(@attributes)
  end
  
  it "should automatically geocode the address" do
    user = User.create!(@attributes)
    user.lat.should == @loc.lat
    user.lng.should == @loc.lng
  end
  
  it "should error if there is nothing in the email address" do
    @attributes.delete(:email)
    u = User.new(@attributes)
    u.should_not be_valid
    u.errors.on(:email).should == "Please enter a valid email address"
  end

  it "should have a valid email address" do
    @attributes[:email] = "diddle@"
    u = User.new(@attributes)
    u.should_not be_valid
    u.errors.on(:email).should == "Please enter a valid email address"    
  end
  
  it "should be able to store the attribute location" do
    u = User.new
    u.location = Location.new(1.0, 2.0)
    u.lat.should == 1.0
    u.lng.should == 2.0
    u.location.lat.should == 1.0
    u.location.lng.should == 2.0
  end
  
  it "should handle location being nil" do
    u = User.new
    u.location = nil
    u.lat.should be_nil
    u.lng.should be_nil
    u.location.should be_nil
  end
  
  it "should error if the address is empty" do
    Location.stub!(:geocode).and_return(Location.new(nil, nil))
    @attributes.delete(:address)
    u = User.new(@attributes)
    u.should_not be_valid
    u.errors.on(:address).should == "Please enter a valid street address"
  end
  
  it "should error if the street address is not in australia" do
    @loc.stub!(:country_code).and_return("US")
    @attributes[:address] = "New York"
    u = User.new(@attributes)
    u.should_not be_valid
    u.errors.on(:address).should == "Please enter a valid street address in Australia"
  end
  
  it "should error if there are multiple matches from the geocoder" do
    @loc.stub!(:all).and_return([@loc, nil])
    @loc.stub!(:full_address).and_return("Bruce Rd, VIC 3885, Australia")

    @attributes[:address] = "Bruce Road"
    u = User.new(@attributes)
    u.should_not be_valid
    u.errors.on(:address).should == "Oops! That's not quite enough information. Please enter a full street address, including suburb and state, e.g. Bruce Rd, VIC 3885"
  end
end
