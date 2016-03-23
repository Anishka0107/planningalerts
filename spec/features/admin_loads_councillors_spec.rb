require "spec_helper"

feature "Admin loads councillors for an authority" do
  given(:authority) { create(:authority,
                             full_name: "Marrickville Council",
                             state: "NSW") }

  scenario "successfully" do
    sign_in_as_admin

    visit admin_authority_path(authority)

    VCR.use_cassette("australian_local_councillors_popolo") do
      click_button "Load Councillors"
    end

    expect(page).to have_content "Successfully loaded 11 councillors"
    expect(page).to have_content "Max Phillips"
    expect(page).to have_content "Chris Woods"
  end

  context "when the authority is from another state" do
    given(:qld_authority) { create(:authority,
                                   full_name: "Toowoomba Regional Council",
                                   state: "QLD") }

    scenario "successfully" do
      sign_in_as_admin

      visit admin_authority_path(qld_authority)

      VCR.use_cassette("australian_local_councillors_popolo") do
        click_button "Load Councillors"
      end

      expect(page).to have_content "Successfully loaded 11 councillors"
      expect(page).to have_content "Sue Englart"
      expect(page).to have_content "John Gouldson"
    end
  end

  context "when councillors don’t have emails" do
    given(:city_of_sydney) do
      create(:authority, full_name: "City of Sydney", state: "NSW")
    end

    scenario "the admin is informed they were not loaded" do
      sign_in_as_admin

      visit admin_authority_path(city_of_sydney)

      VCR.use_cassette("australian_local_councillors_popolo") do
        click_button "Load Councillors"
      end

      expect(page).to have_content "Skipped loading 10 councillors"
    end
  end
end
