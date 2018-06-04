Feature: Team mates
	As a user
	I want to access a team I am member of
	So that I can check my team mates

@javascript
Scenario: show team mates
	Given There is at least a team I am member of
	And I am on the team index page
	When I click on "Mostra Squadra"
	Then I should see my team mates nickname