require "spec_helper"

describe PopoloCouncillors do
  describe "#for_authority" do
    it "finds councillors for a named authority" do
      popolo_file = Rails.root.join("spec", "fixtures", "local_councillor_popolo.json")
      popolo_councillors = PopoloCouncillors.new(EveryPolitician::Popolo::read(popolo_file))

      expected_persons_array = [
        EveryPolitician::Popolo::Person.new(
          id: "albury_city_council/kevin_mack",
          name: "Kevin Mack",
          email: "kevin@albury.nsw.gov.au",
          image: "https://example.com/kevin.jpg",
          party: nil
        ),
        EveryPolitician::Popolo::Person.new(
          id: "albury_city_council/ross_jackson",
          name: "Ross Jackson",
          email: "ross@albury.nsw.gov.au",
          party: "Liberal"
        )
      ]
      expect(popolo_councillors.for_authority("Albury City Council")).to eql expected_persons_array
    end
  end

  describe "#person_with_party_for_membership" do
    it "returns a person with their party" do
      # TODO: Why is this the only test not using the fixture file?
      # We should choose one or the other for consistency
      popolo = Everypolitician::Popolo::JSON.new(
        persons: [{ name: "Kevin Mack", id: "kevin_mack" }],
        organizations: [
          {
            name: "Sunripe Tomato Party",
            id: "sunripe_tomato_party",
            classification: "party"
          },
          {
            name: "Marrickville Council",
            id: "marrickville_council",
            classification: "legislature"
          }
        ],
        memberships: [
          {
            person_id: "kevin_mack",
            organization_id: "marrickville_council",
            on_behalf_of_id: "sunripe_tomato_party"
          }
        ]
      )
      popolo_councillors = PopoloCouncillors.new(popolo)
      membership = popolo.memberships.first

      expect(popolo_councillors.person_with_party_for_membership(membership).party)
        .to eq "Sunripe Tomato Party"
      expect(popolo_councillors.person_with_party_for_membership(membership).name)
        .to eq "Kevin Mack"
    end
  end
end
