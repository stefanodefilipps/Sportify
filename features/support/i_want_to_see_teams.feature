Feature: I want to see my teams
	As a user
	I want to have a team section
	So that i can see the teams i am a member of

Scenario: find teams
	Given I am on the home page
	And There is at least a team
	When I click on "Teams"
	Then i should see the teams names