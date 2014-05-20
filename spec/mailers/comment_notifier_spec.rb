require 'spec_helper'

describe CommentNotifier do
  describe "notify" do
    before :each do
      authority = mock_model(Authority, :full_name => "Foo Council", :email => "foo@bar.gov.au")
      application = mock_model(Application, :authority => authority, :address => "12 Foo Rd", :council_reference => "X/001", :description => "Building something", :id => 123)
      @comment = mock_model(Comment, :email => "foo@bar.com", :name => "Matthew", :application => application, :confirm_id => "abcdef", :text => "It's a good thing.\n\nOh yes it is.", :address => "1 Bar Street")
    end
  
    it "should be sent to the planning authority's feedback email address" do
      notifier = CommentNotifier.notify(@comment)
      notifier.to.should == [@comment.application.authority.email]
    end
    
    it "should have the sender as the main planningalerts email address" do
      notifier = CommentNotifier.notify(@comment)
      notifier.sender.should == "contact@planningalerts.org.au"
    end

    it "should be from the email address of the person who made the comment" do
      notifier = CommentNotifier.notify(@comment)
      notifier.from.should == [@comment.email]
    end

    it "should say in the subject line it is a comment on a development application" do
      notifier = CommentNotifier.notify(@comment)
      notifier.subject.should == "Comment on application X/001"
    end
    
    it "should have specific information in the body of the email" do
      notifier = CommentNotifier.notify(@comment)
      notifier.text_part.body.to_s.should == Rails.root.join("spec/mailers/regression/comment_notifier/email1.txt").read
    end

    it "should format paragraphs correctly in the html version of the email" do
      notifier = CommentNotifier.notify(@comment)
      notifier.html_part.body.to_s.should == Rails.root.join("spec/mailers/regression/comment_notifier/email1.html").read
    end
  end
end