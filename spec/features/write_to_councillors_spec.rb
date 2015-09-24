require 'spec_helper'

feature "Send a message to a councillor" do
  # As someone interested in a local development application,
  # let me write to my local councillor about it,
  # so that I can get their help or feedback
  # and find out where they stand on this development I care about

  context "when not logged in" do
    background do
      authority = create(:authority, full_name: "Foo")
      VCR.use_cassette('planningalerts') do
        application = create(:application, id: "1", authority_id: authority.id, comment_url: 'mailto:foo@bar.com')
        visit application_path(application)
      end
    end

    scenario "can’t see councillor messages sections" do
      page.should_not have_content("Who should this go to?")
      # TODO: and you should not be able to write and submit a message.
    end
  end

  context "when logged in as admin" do
    background do
      @council_or_councillor_explanation = "Write to the council
                                            if you want your comment considered
                                            when they decide whether to approve this application."
      admin = create(:admin)

      visit new_user_session_path
      within("#new_user") do
        fill_in "Email", with: admin.email
        fill_in "Password", with: admin.password
      end
      click_button "Sign in"
      expect(page).to have_content "Signed in successfully"
    end

    given(:application) { VCR.use_cassette('planningalerts') { create(:application, id: "1", comment_url: 'mailto:foo@bar.com') } }

    scenario "sending a message" do
      visit application_path(application, with_councillors: "true")
      page.should have_content("Who should this go to?")
      fill_in("Comment", with: "I think this is a really good idea")
      fill_in("Name", with: "Matthew Landauer")

      page.should have_content(@council_or_councillor_explanation)
      within("#comment-receiver-inputgroup") do
        choose "councillor-2"
      end

      fill_in("Email", with: "example@example.com")
      fill_in("Address", with: "11 Foo Street")

      click_button("Post your comment")

      # TODO: the message appears on the page
      # TODO: the message is sent off to the councillor
    end
  end
end
