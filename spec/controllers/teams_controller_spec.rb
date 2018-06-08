require 'rails_helper'
require 'spec_helper'

RSpec.describe TeamsController, type: :controller do

	describe "GET #index" do
	    it "finds the user passed in the url" do
	    	user = User.create(nick: "stfn", roles: [:captain])
	    	session[:user_id] = user.id
	    	get :index, params: { user_id: user.id }
	    	expect(assigns(:user)).to eq(user)
	    end
	    it "finds the teams associated to the user specified in the url" do
	    	user = User.create(nick: "stfn", roles: [:captain])
	    	team = Team.new(capitano_id: user.id, nome: "prova")
	    	membro = Membro.create(team_id: team.id, user_id: user.id, ruolo: "P")
	    	team.save
	    	session[:user_id] = user.id
	    	get :index, params: { user_id: user.id }
	    	assigns(:teams).each {|t| puts t.nome}
	    	expect(assigns(:teams)).to eq(user.team)
	    end
	    it "renders the :index view" do
	    	user = User.create(nick: "stfn", roles: [:captain])
	    	session[:user_id] = user.id
	    	get :index, params: { user_id: user.id }
    		response.should render_template :index
	    end
	end

	describe "GET #new" do
		it "finds the user passed in the url" do
			user = User.create(nick: "stfn", roles: [:captain])
	    	session[:user_id] = user.id
	    	get :index, params: { user_id: user.id }
	    	expect(assigns(:user)).to eq(user)
		end
	end

	describe "POST #create" do

		before :each do
			@user = User.create(nick: "stfn")
			@giorgio = User.create(nick: "cogiorgio")
	    	session[:user_id] = @user.id
	    	@params = {:user_id => @user.id, :nome => "prova", :A => "stfn", :P => "cogiorgio", :C1 => "", :C2 => "", :D => "" }
		end

		before "capitano non included in squadra" do
	    	@params2 = {:user_id => @user.id, :nome => "prova", :A => "", :P => "cogiorgio", :C1 => "", :C2 => "", :D => "" }
		end

		before "user non esistente" do
			@params3 = {:user_id => @user.id, :nome => "prova", :A => "stfn", :P => "", :C1 => "byuftyfv", :C2 => "", :D => "" }
		end

		before "user presente due volte nella squadra" do
			@params4 = {:user_id => @user.id, :nome => "prova", :A => "stfn", :P => "cogiorgio", :C1 => "cogiorgio", :C2 => "", :D => "" }
		end

		context "with valid attributes" do
			it "finds the user who will become the captain" do
				post :create, params: @params
				expect(assigns(:capitano)).to eq(@user)
			end
			it "creates a notification for the users invited to the team" do
				expect{
        			post :create, params: @params
      			}.to change(Notification,:count).by(1)
			end
			it "add the captain to the team" do
				expect{
					post :create, params: @params
				}.to change(Membro,:count).by(1)
				expect(assigns(:team).capitano).to eq(@user)
			end
			it "add the captain role to the creator of the team" do
				post :create, params: @params
				expect(assigns(:capitano).role_symbols).to eq([:captain])
			end
			it "create a new team" do
				expect{
					post :create, params: @params
				}.to change(Team,:count).by(1)
			end
			it "set the flash hash to notify the success" do
				post :create, params: @params
				expect(flash[:success_cd]).to eq("Nuova squadra creata con successo")
			end
			it "redirect to the team index page" do
				post :create, params: @params
				expect(response).to redirect_to user_teams_path @user
			end
		end

		context "capitano not included in squadra" do
			it "finds the user who will become the captain" do
				post :create, params: @params2
				expect(assigns(:capitano)).to eq(@user)
			end
			it "doesn't send any notifications" do
				expect{
					post :create, params: @params2
				}.to_not change(Notification,:count)
			end
			it "doesn't create the team" do 
				expect{
					post :create, params: @params2
				}.to_not change(Team,:count)
			end
			it "set the flash error hash" do
				post :create, params: @params2
				expect(flash[:error_cd]).to eq "Creazione Fallita. Il capitano deve essere in squadra"
			end
			it "redirect to the team index page" do
				post :create, params: @params2
				expect(response).to redirect_to user_teams_path @user
			end
		end

		context "user non esistente" do
			it "finds the user who will become the captain" do
				post :create, params: @params3
				expect(assigns(:capitano)).to eq(@user)
			end
			it "doesn't create the team" do 
				expect{
					post :create, params: @params3
				}.to_not change(Team,:count)
			end
			it "set the flash error hash" do
				post :create, params: @params3
				expect(flash[:error_cd]).to eq "User byuftyfv non esistente"
			end
			it "redirect to the team index page" do
				post :create, params: @params3
				expect(response).to redirect_to user_teams_path @user
			end
		end
	end

	describe "GET #show" do
		
		before :each do
			@user = User.new(nick: "stfn", roles: [:captain])
			@user.save
			@team = Team.new(capitano_id: @user.id, nome: "prova")
	    	membro = Membro.new(ruolo: "P")
	    	membro.team = @team
	    	membro.user = @user
	    	membro.save
	    	@team.save
	    	session[:user_id] = @user.id
	    	@params = {:user_id => @user.id, :id => @team.id, format: :js}
		end

		before "with user not existent" do
			@params2 = {:user_id => 3, :id => @team.id, format: :js}
		end

		before "with user not existent" do
			@params3 = {:user_id => @user.id, :id => 34, format: :js}
		end

		context "With user and team present in the database" do
			it "finds the user in the url" do
				get :show, params: @params
				expect(assigns(:user)).to eq(@user)
			end
			it "finds the team in the url" do
				get :show, params: @params
				expect(assigns(:team)).to eq(@team)
			end
			it "send the js file" do
				get :show, params: @params
				expect(response.headers["Content-Type"]).to eq "text/javascript; charset=utf-8"
			end
		end

		context "with user not existent" do
			it "flash[error]" do
				get :show, params: @params2
				expect(flash[:error]).to eq "User non esistente"
			end
			it "redirect to teams index page" do
				get :show, params: @params2
				expect(response).to redirect_to user_teams_path @user
			end
		end

		context "with team non esistente" do
			it "flash[error]" do
				get :show, params: @params3
				expect(flash[:error]).to eq "Team non esistente"
			end

			it "redirect to teams index page" do
				get :show, params: @params3
				expect(response).to redirect_to user_teams_path @user
			end
		end
	end

	describe "PUT #update" do

		before :each do
			@user = User.new(nick: "stfn", roles: [:captain])
			@user.save
			@team = Team.new(capitano_id: @user.id, nome: "prova")
	    	membro = Membro.new(ruolo: "P")
	    	membro.team = @team
	    	membro.user = @user
	    	membro.save
	    	@team.save
	    	session[:user_id] = @user.id
	    	@params = {:user_id => @user.id, :id => @team.id, :nome => "Cambiato", format: :js}
		end

		before "with name empty" do
			@params2 = {:user_id => @user.id, :id => @team.id, :nome => "", format: :js}
		end

		before "not captain" do
			@giorgio = User.new(nick: "cogiorgio", roles: [:captain])
			@giorgio.save 
			@team2 = Team.new(capitano_id: @giorgio.id, nome: "prova2")
	    	membro = Membro.new(ruolo: "P")
	    	membro.team = @team2
	    	membro.user = @user
	    	membro.save
	    	membro = Membro.new(ruolo: "A")
	    	membro.team = @team2
	    	membro.user = @giorgio
	    	membro.save
	    	@params3 = {:user_id => @user.id, :id => @team2.id, :nome => "", format: :js}
		end

		context "with valid attributes" do
			it "finds the team in the url" do
				put :update, params: @params
				expect(assigns(:team)).to eq(@team)
			end
			it "sets the new name for the team" do
				put :update, params: @params
				@team.reload
				expect(@team.nome).to eq "Cambiato"
			end
			it "sets the flash[:success] hash" do
				put :update, params: @params
				expect(flash[:success]).to eq "Nome cambiato con successo"
			end
		end

		context "with name empty" do
			it "finds the team in the url" do
				put :update, params: @params2
				expect(assigns(:team)).to eq(@team)
			end

			it "doesn't change the team name" do
				put :update, params: @params2
				@team.reload
				expect(@team.nome).to eq("prova")
			end

			it "sets the flas[:error] hash" do
				put :update, params: @params2
				expect(flash[:error]).to eq "Aggiungere un nuovo nome"
			end
		end

		context "not captain" do
			it "finds the team in the url" do
				put :update, params: @params3
				expect(assigns(:team)).to eq(@team2)
			end

			it "redirect to team index page" do
				put :update, params: @params3
				expect(response).to redirect_to user_teams_path @user
			end

			it "set the flash[:error]" do
				put :update, params: @params3
				expect(flash[:error]).to eq "non sei autorizzato a modificare questa squadra"
			end

		end
	end

	describe "DELETE #destroy" do
		before :each do
			@user = User.new(nick: "stfn", roles: [:captain])
			@user.save
			@team = Team.new(capitano_id: @user.id, nome: "prova")
	    	membro = Membro.new(ruolo: "P")
	    	membro.team = @team
	    	membro.user = @user
	    	membro.save
	    	@team.save
	    	session[:user_id] = @user.id
	    	@params = {:user_id => @user.id, :id => @team.id, format: :js}
		end

		context "with correct parameters" do
			it "finds the team in the url" do
				delete :destroy, params: @params
				expect(assigns(:team)).to eq(@team)
			end
			it "delete the team" do
				expect{
			      delete :destroy, params: @params       
			    }.to change(Team,:count).by(-1)
			end

			it "redirect to index team page" do
				delete :destroy, params: @params
				expect(response).to redirect_to user_teams_path @user
			end
		end
	end

	describe "PUT #leave" do
		before :each do
			@user = User.new(nick: "stfn", roles: [:captain])
			@user.save
			@giorgio = User.new(nick: "cogiorgio", roles: [:captain])
			@giorgio.save 
			@team = Team.new(capitano_id: @giorgio.id, nome: "prova2")
	    	membro = Membro.new(ruolo: "P")
	    	membro.team = @team
	    	membro.user = @user
	    	membro.save
	    	membro = Membro.new(ruolo: "A")
	    	membro.team = @team2
	    	membro.user = @giorgio
	    	membro.save
	    	session[:user_id] = @user.id
	    	@params = {:user_id => @user.id, :id => @team.id, :nome => "", format: :js}
		end

		context "i am part of the team" do
			it "finds the team in the url" do
				put :leave, params: @params
				expect(assigns(:team)).to eq(@team)
			end
			it "finds the user in the url" do
				put :leave, params: @params
				expect(assigns(:user)).to eq(@user)
			end
			it "delete current user from the team" do
				expect{
			      put :leave, params: @params       
			    }.to change(Membro,:count).by(-1)
			end
			it "redirect to index team page" do
				put :leave, params: @params
				expect(response).to redirect_to user_teams_path @user
			end
		end
	end

	describe "PUT #remove" do

		before :each do
			@user = User.new(nick: "stfn", roles: [:captain])
			@user.save
			@giorgio = User.new(nick: "cogiorgio", roles: [:captain])
			@giorgio.save 
			@team = Team.new(capitano_id: @user.id, nome: "prova2")
	    	membro = Membro.new(ruolo: "P")
	    	membro.team = @team
	    	membro.user = @user
	    	membro.save
	    	membro = Membro.new(ruolo: "A")
	    	membro.team = @team
	    	membro.user = @giorgio
	    	membro.save
	    	session[:user_id] = @user.id
	    	@params = {:user_id => @user.id, :team_id => @team.id, :user => @giorgio.id, :nome => "", format: :js}
		end

		context "i am captain" do
			it "finds user in url" do
				put :remove, params: @params
				expect(assigns(:user)).to eq @user
			end
			it "finds the team in url" do
				put :remove, params: @params
				expect(assigns(:team)).to eq @team
			end
			it "finds the user to remove" do
				put :remove, params: @params
				expect(assigns(:user_to_remove)).to eq @giorgio
			end
			it "deletes the user from the team" do
				expect{
			      put :remove, params: @params       
			    }.to change(Membro,:count).by(-1)
			end

			it "set flash[:success]" do
				put :remove, params: @params
				expect(flash[:success]).to eq "#{@giorgio.nick} è stato eliminato"
			end
		end


	end
end
