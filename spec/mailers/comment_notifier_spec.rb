require 'spec_helper'

describe CommentNotifier do
  describe "#notify_authority" do
    before :each do
      application = mock_model(Application, authority: create(:contactable_authority), address: "12 Foo Rd", council_reference: "X/001", description: "Building something", id: 123)
      @comment = create(:confirmed_comment, email: "foo@bar.com", name: "Matthew", application: application, text: "It's a good thing.\n\nOh yes it is.", address: "1 Bar Street")
    end

    context "default theme" do
      let(:notifier) { CommentNotifier.notify_authority("default", @comment) }

      it "should be sent to the planning authority's feedback email address" do
        notifier.to.should == [@comment.application.authority.email]
      end

      it "should have the sender as the main planningalerts email address" do
        notifier.sender.should == "contact@planningalerts.org.au"
      end

      it "should be from the email address of the person who made the comment" do
        notifier.from.should == [@comment.email]
      end

      it "should say in the subject line it is a comment on a development application" do
        notifier.subject.should == "Comment on application X/001"
      end

      it "should have specific information in the body of the email" do
        notifier.text_part.body.to_s.should == Rails.root.join("spec/mailers/regression/comment_notifier/email1.txt").read
      end

      it "should format paragraphs correctly in the html version of the email" do
        notifier.html_part.body.to_s.should include Rails.root.join("spec/mailers/regression/comment_notifier/email1.html").read
      end

      context "when the comment is for a councillor" do
        before do
          @comment.update councillor_id: create(:councillor).id
        end

        it "should be sent to the Councillor's email address" do
          notifier.to.should == [@comment.councillor.email]
        end
      end
    end

    context "nsw theme" do
      let(:notifier) { CommentNotifier.notify_authority("nsw", @comment) }

      it "should be sent to the planning authority's feedback email address" do
        notifier.to.should == [@comment.application.authority.email]
      end

      it "should have the sender as the nsw planningalerts email address" do
        notifier.sender.should == "contact@nsw.127.0.0.1.xip.io"
      end

      it "should be from the email address of the person who made the comment" do
        notifier.from.should == [@comment.email]
      end

      it "should say in the subject line it is a comment on a development application" do
        notifier.subject.should == "Comment on application X/001"
      end

      it "should have specific information in the body of the email" do
        notifier.text_part.body.to_s.should == Rails.root.join("spec/mailers/regression/comment_notifier/email2.txt").read
      end

      it "should format paragraphs correctly in the html version of the email" do
        notifier.html_part.body.to_s.should include Rails.root.join("spec/mailers/regression/comment_notifier/email2.html").read
      end

      context "when the comment is for a councillor" do
        before do
          @comment.update councillor_id: create(:councillor).id
        end

        it "should be sent to the Councillor's email address" do
          notifier.to.should == [@comment.councillor.email]
        end
      end
    end
  end
end
