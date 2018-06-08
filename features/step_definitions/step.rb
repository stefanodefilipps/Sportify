
#require "rails_helper"
#require 'spec_helper'
require '././spec/spec_helper'
require "cancan/matchers"

Given("I am on the match index page") do
  @user = create(:user, voto: 0, tot: 0)
  page.set_rack_session(user_id: @user.id)
  visit user_matches_path @user
end

Given("There is at least a team") do
  @team = create(:team, capitano_id: @user.id)
  create(:membro, team_id: @team.id, user_id: @user.id)
  user = create(:user, nome: "Giorgio", cognome: "Coccia", nick: "cogiorgio", voto: 0, tot: 0)
  @team2 = create(:team, nome: "stefanino", capitano_id: user.id)
  create(:membro, team_id: @team2.id, user_id: user.id)
  create(:membro, team_id: @team2.id, user_id: @user.id, ruolo: "A")
end

When("I click on \"Teams\"") do
  find("a[href=\'#{user_teams_path(@user)}\']").click
end

Then("I should see the teams names") do
	expect(page).to have_content("#{@team.nome}")
	expect(page).to have_content("#{@team2.nome}")
end

Given("There is at least a team I am not member of") do
	user = create(:user, nome: "Giorgio", cognome: "Coccia", nick: "cogiorgio", roles: :captain, voto: 0, tot: 0)
	@team2 = create(:team, nome: "stefanino", capitano_id: user.id)
	@team = create(:team, capitano_id: @user.id)
  	create(:membro, team_id: @team.id, user_id: @user.id)
  	create(:membro, team_id: @team2.id, user_id: user.id)
end

Then("I should not see the name of that team") do
	expect(page).to have_no_content("#{@team2.nome}")
end

Given("I am on the team index page") do
  if !@user
    @user = create(:user, roles: :captain)
  end
  page.set_rack_session(user_id: @user.id)
  visit user_teams_path(@user)
end

Given("There is at least a team I am member of") do
  @user = create(:user, roles: :captain, voto: 0, tot: 0)
  @team = create(:team, capitano_id: @user.id)
  @user.roles << :captain
  @user.save
  create(:membro, team_id: @team.id, user_id: @user.id)
  @user2 = create(:user, nome: "Giorgio", cognome: "Coccia", nick: "cogiorgio")
  create(:membro, team_id: @team.id, user_id: @user2.id, ruolo: "A")
end

When("I click on \"Mostra Squadra\"") do
  click_link("Mostra Squadra")
end

When("I click on \"Mostra Squadra\" of the first team") do
  click_link("Mostra Squadra")
end

Then("I should see my team mates nickname") do
  expect(page).to have_content("#{@team.nome}")
  @team.membro.each do |m|
    expect(page).to have_selector("input[value=\'#{m.user.nick}\']")
  end
end

Given("There is at least a team I am captain of") do
  @user.roles << :captain
  @user.save
  @team = create(:team, capitano_id: @user.id)
  @user2 = create(:user, nome: "Giorgio", cognome: "Coccia", nick: "cogiorgio")
  create(:membro, team_id: @team.id, user_id: @user.id)
  create(:membro, team_id: @team.id, user_id: @user2.id, ruolo: "A")
end

Then("I should see the team name") do
  expect(page).to have_content("#{@team.nome}")
end

Then("I should see my team mates nicknames") do
  @team.membro.each do |m|
    expect(page).to have_selector("input[value=\'#{m.user.nick}\']")
  end
end

Then("I should see my team name") do
  expect(page).to have_content("#{@team.nome}")
end

Then("I should see \"Rimuovi utente\" for every member unless he is the captain") do
  expect(page).to have_css("a", :text => "Rimuovi utente", :count => @team.membro.size-1)
end

When("I click on \"Rimuovi utente\" of the first member") do
  click_link("Rimuovi utente")
end

Then("I should see the same team") do
  expect(page).to have_content("#{@team.nome}")
  @team.membro.each do |m|
    if m.user.nick != @user2.nick
      expect(page).to have_selector("input[value=\'#{m.user.nick}\']")
    end
  end
end

Then("I should not see the nickname of the deleted member") do
  expect(page).to have_no_selector("input[value=\'#{@user2.nick}}\']")
end

When("I click on \"Crea Squadra\"") do
  click_link("Crea Squadra")
end

Then("I should see the creation form") do
  expect(page).to have_content("Crea Squadra")
  expect(page).to have_selector("input#P")
  expect(page).to have_selector("input#D")
  expect(page).to have_selector("input#C1")
  expect(page).to have_selector("input#C2")
  expect(page).to have_selector("input#A")
  expect(page).to have_selector("input[value=\"Crea Squadra\"]")
end

Then("I should provide a name of the team") do
  fill_in "nome", with: "Team_Prova"
end

Then("I should choose a role") do
  fill_in "A", with: "#{@user.nick}"
end

Then("I should invite another user") do
  @giorgio = User.create(nome: "Giorgio", cognome: "Coccia", nick: "cogiorgio", voto: 0, tot: 0)
  fill_in "C1", with: "#{@giorgio.nick}"
end

When("I push on \"Crea Squadra\"") do
  page.find('input[name="commit"]').click
end

Then("I should be on the team index page") do
  page.current_url.should eq "https://localhost:3001/users/#{@user.id}/teams"
end

Then("I should see the new team created") do
  expect(page).to have_content("Team_Prova")
end

Then("I should see the name of the team created") do
  expect(page).to have_content("Team_Prova")
end

Then("I should see the actual member of the team") do
  t = Team.find_by(nome: "Team_Prova")
  t.membro.each do |m|
    expect(page).to have_selector("input[value=\'#{m.user.nick}\']")
  end
end

Given("I am not on the team Prova") do
  @giorgio = User.create(nome: "Giorgio",cognome: "Coccia", nick: "cogiorgio", roles: :captain, voto: 0, tot: 0)
  @team = Team.create(nome: "Prova", capitano_id: @giorgio.id)
  membro = Membro.create(user_id: @giorgio.id, team_id: @team.id, ruolo: "A")
  @stefano = User.create(nome: "Stefano",cognome: "De Filippis", nick: "stfn", voto:0, tot: 0)
  @notification = Notification.create(tipo: 2, data: Date.today, ora: Time.now, msg: "#{@giorgio.nick} ti ha invitato a partecipare alla squadra Prova", sender_id: @giorgio.id, receiver_id: @stefano.id)
  sq = Sq.create(team_id: @team.id, notification_id: @notification.id, ruolo: "P")
end

Given("I am on the user show page") do
  page.set_rack_session(user_id: @stefano.id)
  visit user_path(@stefano)
end

Given("I have been invited to the team Prova") do
  expect(page).to have_content("#{@giorgio.nick} ti ha invitato a partecipare alla squadra Prova")
end

When("I click on \"Accetta\" of Prova notification") do
  find("input[value=\"accept\"]").click
end

Given("I am on the index team page") do
  visit user_teams_path @stefano
end

Given("I should see the name of the new team") do
  expect(page).to have_content("#{@team.nome}")
end

Then("I should see the name of the team") do
  expect(page).to have_content("#{@team.nome}")
end

Then("I should see the Leave Button") do
  expect(page).to have_css("a", :text => "Abbandona squadra")
end

Then("I should see the Back Button") do
  expect(page).to have_css("a", :text => "Back")
end

When("I click on \"Rifiuta\" of Prova notification") do
  find("input[value=\"deny\"]").click
end

Then("I should not see the name of the new team") do
  expect(page).to have_no_content("#{@team.nome}")
end

Then("I should see the message error") do
  expect(page).to have_content("Creazione Fallita. Il capitano deve essere in squadra")
end