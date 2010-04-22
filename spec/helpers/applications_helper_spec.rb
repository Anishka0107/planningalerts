require 'spec_helper'

describe ApplicationsHelper do
  before :each do
    authority = mock_model(Authority, :full_name => "An authority", :short_name => "Blue Mountains")
    @application = mock_model(Application, :map_url => "http://a.map.url",
      :description => "A planning application", :council_reference => "A1", :authority => authority, :info_url => "http://info.url", :comment_url => "http://comment.url",
      :on_notice_from => nil, :on_notice_to => nil)
  end

  describe "scraped_and_received_text" do
    before :each do
      @application.stub!(:address).and_return("foo")
      @application.stub!(:lat).and_return(1.0)
      @application.stub!(:lng).and_return(2.0)
      @application.stub!(:location).and_return(Location.new(1.0, 2.0))
    end

    it "should say when the application was received by the planning authority and when it appeared on PlanningAlerts" do
      @application.stub!(:date_received).and_return(20.days.ago)
      @application.stub!(:date_scraped).and_return(18.days.ago)
      helper.scraped_and_received_text(@application).should ==
        "We found this application for you on the planning authority's website 18 days ago. It was received by them 2 days earlier."
    end
    
    it "should say something appropriate when the received date is not known" do
      @application.stub!(:date_received).and_return(nil)
      @application.stub!(:date_scraped).and_return(18.days.ago)
      helper.scraped_and_received_text(@application).should ==
        "We found this application for you on the planning authority's website 18 days ago. The date it was received by them was not recorded."
    end
  end
  
  describe "on_notice_text" do
    before :each do
      @application.stub!(:address).and_return("foo")
      @application.stub!(:lat).and_return(1.0)
      @application.stub!(:lng).and_return(2.0)
      @application.stub!(:location).and_return(Location.new(1.0, 2.0))
      @application.stub!(:date_received).and_return(nil)
      @application.stub!(:date_scraped).and_return(Time.now)
    end
    
    it "should say when the application is on notice (and hasn't started yet)" do
      @application.stub!(:on_notice_from).and_return(2.days.from_now)
      @application.stub!(:on_notice_to).and_return(16.days.from_now)
      helper.on_notice_text(@application).should ==
        "The period for officially responding to this application starts in 2 days and finishes 14 days later."
    end
    
    describe "period is in progress" do
      before :each do
        @application.stub!(:on_notice_from).and_return(2.days.ago)
        @application.stub!(:on_notice_to).and_return(12.days.from_now)
      end
      
      it "should say when the application is on notice" do
        helper.on_notice_text(@application).should ==
          "You have 12 days left to officially respond to this application. The period for comment started 2 days ago."
      end
    
      it "should only say when on notice to if there is no on notice from information" do
        @application.stub!(:on_notice_from).and_return(nil)
        helper.on_notice_text(@application).should ==
          "You have 12 days left to officially respond to this application."
      end
    end
    
    describe "period is finished" do
      before :each do
        @application.stub!(:on_notice_from).and_return(16.days.ago)
        @application.stub!(:on_notice_to).and_return(2.days.ago)
      end
      
      it "should say when the application is on notice" do
        helper.on_notice_text(@application).should ==
          "You're too late! The period for officially commenting on this application finished 2 days ago. It lasted for 14 days."
      end
    
      it "should only say when on notice to if there is no on notice from information" do
        @application.stub!(:on_notice_from).and_return(nil)
        helper.on_notice_text(@application).should ==
          "You're too late! The period for officially commenting on this application finished 2 days ago."
      end
    end
  end
end
