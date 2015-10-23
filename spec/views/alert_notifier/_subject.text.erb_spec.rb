require "spec_helper"

describe "alert_notifier/_subject.text.erb" do
  let(:alert) { create(:alert, address: "123 Sample St") }
  let(:application) do
    mock_model(Application, address: "Bar Street",
    description: "Alterations & additions", council_reference: "007",
    location: double("Location", lat: 1.0, lng: 2.0))
  end
  let(:comment) { create(:comment, application: application) }

  context "with an application" do
    subject { render "alert_notifier/subject", alert: alert, applications: [application], comments: [] }
    it { should eql "1 new planning application near 123 Sample St\n" }
  end

  context "with a comment" do
    subject { render "alert_notifier/subject", alert: alert, applications: [], comments: [comment] }
    it { should eql "1 new comment on planning applications near 123 Sample St\n" }
  end

  context "with an application and a comment" do
    subject { render "alert_notifier/subject", alert: alert, applications: [application], comments: [comment] }
    it { should eql "1 new comment and 1 new planning application near 123 Sample St\n" }
  end
end
