Feature: Cancel Member
	As a captain
	I want to have special settings
	So that I can delete a member from the team

@javascript
Scenario: cancel a member
	Given I am on the match index page
	And There is at least a team I am captain of
	When I click on "Teams"
	Then I should see the team name
	When I click on "Mostra Squadra" of the first team
	Then I should see my team mates nicknames
	And I should see my team name
	And I should see "Rimuovi utente" for every member unless he is the captain
	When I click on "Rimuovi utente" of the first member
	Then I should see the same team 
	And I should not see the nickname of the deleted member