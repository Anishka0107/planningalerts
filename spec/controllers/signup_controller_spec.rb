require 'spec_helper'

describe SignupController, "confirming" do
  it "should set the alert to be confirmed" do
    alert = mock_model(Alert)
    Alert.should_receive(:find_by_confirm_id).with("1234").and_return(alert)
    alert.should_receive(:confirmed=).with(true)
    alert.should_receive(:save!)
    get :confirmed, :cid => "1234"
  end
  
  it "should return a 404 when the wrong confirm_id is used" do
    get :confirmed, :cid => "1111"
    response.code.should == "404"
  end
end
