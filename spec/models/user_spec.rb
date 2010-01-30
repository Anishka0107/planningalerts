require 'spec_helper'

describe User do
  before :each do
    @address = "24 Bruce Road, Glenbrook, NSW"
    @attributes = {:email => "matthew@openaustralia.org", :address => @address,
      :area_size_meters => 200}
  end

  it "should have no trouble creating a user with valid attributes" do
    User.create!(@attributes)
  end
  
  it "should automatically geocode the address" do
    loc = Location.new(1.0, 2.0)
    Location.should_receive(:geocode).with(@address).and_return(loc)
    user = User.create!(@attributes)
    user.location.distance_to(loc).should < 1
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
end
