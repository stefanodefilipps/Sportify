Feature: I want to see my teams
	As a user
	I want to have a team section
	So that i can see the teams i am a member of

Scenario: find teams
	Given I am on the match index page
	And There is at least a team
	When I click on "Teams"
	Then I should see the teams names

Scenario: not my teams
	Given I am on the match index page
	And There is at least a team I am not member of
	When I click on "Teams"
	Then I should not see the name of that team