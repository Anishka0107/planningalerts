Feature: Give feedback to Council
  In order to affect the outcome of a development application
  As a citizen
  I want to send feedback on a development application directly to the planning authority
    
  Scenario: Unconfirmed comment should not be shown
    Given a planning authority "Foo" with a feedback email "feedback@foo.gov.au"
    And an application "1" in planning authority "Foo"
    And an unconfirmed comment "I think this is a really good ideas" on application "1"
    When I go to application page "1"
    Then I should not see "I think this is a really good ideas"

  Scenario: Confirming the comment
    Given a planning authority "Foo" with a feedback email "feedback@foo.gov.au"
    And an application "1" in planning authority "Foo"
    And an unconfirmed comment "I think this is a really good ideas" on application "1"
    When I go to the confirm page for comment "I think this is a really good ideas"
    Then I should see "Thanks. Your comment has been sent to Foo and is now visible on this page."
    And I should see "I think this is a really good ideas"
    And "feedback@foo.gov.au" should receive an email
    When "feedback@foo.gov.au" opens the email
    Then they should see "I think this is a really good ideas" in the email body

  Scenario: Reporting abuse on a confirmed comment
    Given a moderator email of "moderator@planningalerts.org.au"
    And a confirmed comment "I'm saying something abusive" by "Jack Rude" with email "rude@foo.com" and id "23"
    When I go to the report page for comment "I'm saying something abusive"
    And I fill in "Your name" with "Joe Reporter"
    And I fill in "Your email" with "reporter@foo.com"
    And I fill in "Details" with "You can't be rude to people!"
    And I press "Send report"
    Then I should see "The comment has been reported and a moderator will look into it as soon as possible."
    And I should see "Thanks for taking the time let us know about this."
    And "moderator@planningalerts.org.au" should receive an email
    When they open the email
    Then they should see the email delivered from "Joe Reporter <reporter@foo.com>"
    And they should see "PlanningAlerts: Abuse report" in the email subject
