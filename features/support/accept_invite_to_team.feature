Feature: Accept Invite To Team
	As a user
	I want to have a notification center
	So that I can accept the invite to be a member of a team

@javascript
Scenario: create a team
	Given I am not on the team Prova
	And I am on the user show page
	And I have been invited to the team Prova
	When I click on "Accetta" of Prova notification
	Given I am on the index team page
	And I should see the name of the new team
	When I click on "Mostra Squadra"
	Then I should see the name of the team
	And I should see my team mates nicknames
	And I should see the Leave Button
	And I should see the Back Button