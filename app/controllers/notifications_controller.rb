class NotificationsController < ApplicationController

	before_action :require_user
	
	def index
		@notifications = Notification.where(receiver_id: current_user.id)
	end


	def accept
		@notification = Notification.find_by(id: params[:id])
		if !@notification
			puts "Nessuna notifica trovata"
			redirect_to user_path current_user
			return
		end
		authorize! :accept, @notification
		if @notification.tipo == 2
			team = @notification.sq.team
			if !team
				puts "Squadra inesistente"
				@notification.destroy
				redirect_to user_path current_user
				return
			end
			mem = Membro.new
			mem.ruolo = @notification.sq.ruolo 
			mem.team = team
			mem.user = current_user
			begin 										#provo a salvare membro ma devo controllare che l'user non sia gia presente nella squadra altrimenti postgres
				mem = mem.save							#mi lancia l'errore che il record non è unico e quindi se si verifica in questo punto devo cancellare la squadra
			rescue ActiveRecord::RecordNotUnique => e
				puts e.message.upcase
				@notification.destroy
				redirect_to user_path current_user
				return
			end
			if !mem
				puts "Non siamo riusciti ad aggiungerti alla squadra #{team.nome}"
				@notification.destroy
				redirect_to user_path current_user
			end
			if !team.save
				puts "Non siamo riusciti ad aggiungerti alla squadra #{team.nome}"
				@notification.destroy
				mem.destroy
				redirect_to user_path current_user
			end
			puts "Sei stato aggiunto alla squadra #{team.nome}"
			@notification.destroy
		elsif @notification.tipo == 1
			@match=Match.find_by(id:@notification.par.match_id)
			if(@match.uu!=nil)
				if(@match.uu.user.where(id: @notification.receiver_id)[0] == nil)
			    	Gioca.create(user_id: @notification.receiver_id,ruolo:@notification.par.ruolo,squadra:@notification.par.squadra, uu_id: @match.uu.id)	
				end
			else
				if(@match.pt.user.where(id: @notification.receiver_id)[0] == nil &&  ( @match.pt.team[0]==nil || @match.pt.team[0].user.where(id: user.id)[0]==nil ))
					Squadra.create(user_id: @notification.receiver_id,ruolo:@notification.par.ruolo, pt_id: @match.pt.id)
				end
			end
		else
			@match=Match.find_by(id:@notification.par.match_id)
			@team=Team.find_by(nome:@notification.par.team)
			if(@match.pt!=nil)
			    @team.pt << @match.pt
			    @team.save
			else
				if( (@match.tt.team[0]==nil||@match.tt.team[0].user.where(id: current_user.id)[0]==nil) && (@match.tt.team[1]==nil||@match.tt.team[1].user.where(id: current_user.id)[0]==nil))
				@team.tt << @match.tt
				@team.save
				end
			end

		end

		@notification.destroy
		redirect_to user_path current_user
	end

	def deny
		@notification = Notification.find_by(id: params[:id])
		if !@notification
			puts "Nessuna notifica trovata"
			redirect_to user_path current_user
			return
		end
		
			@notification.destroy
			redirect_to user_path current_user
		
	end

end
