require "spec_helper"

feature "Subscribing for access to several alerts" do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    # When plan is set to 0 StripeMock doesn't check for the card number when creating the customer
    # FIXME: StripeMock should create a customer when only a token is supplied
    Subscription::PLAN_IDS.each do |id|
      stripe_helper.create_plan(id: id, amount: 0)
    end
  end
  after { StripeMock.stop }

  given(:email) { "mary@enterpriserealty.com" }

  context "2 alerts signed up" do
    background do
      create(:alert, email: email, confirmed: true, address: "123 King St, Newtown")
      create(:alert, email: email, confirmed: true, address: "456 Marrickville Rd, Marrickville")
    end

    scenario "Signing up for a 3rd alert and subscribing" do
      VCR.use_cassette("planningalerts") do
        visit "/alerts/signup"

        fill_in("alert_email", with: email)
        fill_in("alert_address", with: "24 Bruce Road, Glenbrook")
        click_button("Create alert")
      end

      expect(page).to have_content("Now check your email")

      open_last_email_for(email)
      expect(current_email).to have_subject("Please confirm your planning alert")
      expect(current_email).to have_body_text("24 Bruce Road, Glenbrook NSW 2773")
      click_first_link_in_email

      expect(page).to have_content("you now have alerts set up for 3 street addresses")
      expect(Subscription.find_by!(email: email).trial_days_remaining).to eql 7
      expect(Subscription.find_by!(email: email)).to be_trial
      click_link("subscribe here")

      # Fake what the Stripe JS does (i.e. inject the token in the form if successful)
      # FIXME: This isn't having an effect because we're just setting the plan amout to 0. See comment above.
      first("input[name='stripeToken']", visible: false).set(stripe_helper.generate_card_token)
      click_button("Subscribe now $5/month")

      expect(page).to have_content("Thanks for subscribing!")
      expect(Subscription.find_by!(email: email)).to be_paid
    end
  end

  context "Trial subscription" do
    given(:alert) { create(:alert, email: email, confirmed: true, lat: -33.911105, lng: 151.155503, address: "123 Illawarra Road Marrickville 2204") }
    background do
      create(:subscription, email: email, trial_started_at: Date.today)
      create(:application, address: "252 Illawarra Road Marrickville 2204",
                           description: "A wonderful new house",
                           lat: -33.911105,
                           lng: 151.155503,
                           suburb: "Marrickville",
                           state: "NSW",
                           postcode: "2204")
    end

    scenario "Alerts contain a trial subscription banner that I can click to subscription" do
      alert.process!

      open_email(email)
      expect(current_email).to have_subject("1 new planning application near 123 Illawarra Road Marrickville 2204")
      expect(current_email).to have_body_text("trial subscription")
      visit_in_email("Subscribe")

      expect(page).to have_content("Subscribe now")
      # Fake what the Stripe JS does (i.e. inject the token in the form if successful)
      # FIXME: This isn't having an effect because we're just setting the plan amout to 0. See comment above.
      first("input[name='stripeToken']", visible: false).set(stripe_helper.generate_card_token)
      click_button("Subscribe now $34/month")

      expect(page).to have_content("Thanks for subscribing!")
      expect(Subscription.find_by!(email: email)).to be_paid
    end

    context "expired" do
      background do
        create(:alert, email: email, confirmed: true, address: "123 King St, Newtown")
        create(:alert, email: email, confirmed: true, address: "456 Marrickville Rd, Marrickville")
        Subscription.find_by!(email: email).update(trial_started_at: 7.days.ago)
      end

      scenario "Alerts don't contain the application details any more" do
        alert.process!

        open_email(email)
        expect(current_email).to have_subject("You’re missing out on 1 new planning application near 123 Illawarra Road Marrickville 2204")
        expect(current_email).to_not have_body_text("A wonderful new house")
        expect(current_email).to have_body_text("You need to subscribe to get alerts for several addresses")
      end
    end
  end

  scenario "Show a different price to people with a different plan" do
    create(:subscription, email: email, stripe_plan_id: "planningalerts-15")

    visit(new_subscription_path(email: email))
    expect(page).to have_content("$15/month")
  end
end
