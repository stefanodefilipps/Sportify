Feature: Create Team
	As a user
	I want to create a new team
	So that I can use it in a match

@javascript
Scenario: create a team
	Given I am on the team index page
	When I click on "Crea Squadra"
	Then I should see the creation form
	And I should provide a name of the team
	And I should choose a role
	And I should invite another user
	When I push on "Crea Squadra"
	Then I should be on the team index page
	And I should see the new team created
	When I click on "Mostra Squadra"
	Then I should see the name of the team created
	And I should see the actual member of the team