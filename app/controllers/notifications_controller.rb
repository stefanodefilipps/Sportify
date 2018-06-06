class NotificationsController < ApplicationController
	def index
		@notifications = Notification.where(receiver_id: current_user.id)
	end


	def accept
		@notification = Notification.find_by(id: params[:id])
		if !@notification
			puts "Nessuna notifica trovata"
			redirect_to notifications_path
			return
		end
		authorize! :accept, @notification
		if @notification.tipo == 2
			team = @notification.sq.team
			if !team
				puts "Squadra inesistente"
				@notification.destroy
				redirect_to notifications_path
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
				redirect_to notifications_path
				return
			end
			if !mem
				puts "Non siamo riusciti ad aggiungerti alla squadra #{team.nome}"
				@notification.destroy
				redirect_to notifications_path
			end
			if !team.save
				puts "Non siamo riusciti ad aggiungerti alla squadra #{team.nome}"
				@notification.destroy
				mem.destroy
				redirect_to notifications_path
			end
			puts "Sei stato aggiunto alla squadra #{team.nome}"
		elsif @notification.tipo == 1
			#Qui andrà il codice per gestire l'accetazione di un utente o una squadra a un match
			
		end

		@notification.destroy
		redirect_to notifications_path
	end

	def deny
		@notification = Notification.find_by(id: params[:id])
		if !@notification
			puts "Nessuna notifica trovata"
			redirect_to notifications_path
			return
		end
		if @notification.tipo == 2
			@notification.destroy
			redirect_to notifications_path
		elsif @notification.tipo == 1
			#codice per gestire un eny quando riguardano dei match
            @match=Match.find_by(id: @notification.par.match_id)
			if(@match.uu!=nil)
			@partita=Gioca.find_by(user_id: @notification.receiver_id,uu_id: @match.uu)
				if(@partita!=nil) 
					@partita.destroy
					@notification.destroy
					redirect_to notifications_path
				end
			elsif(@match.pt!=nil)
				@partita=Squadra.find_by(user_id: @notification.receiver_id,pt_id: @match.pt)
				if(@partita!=nil) 
					@partita.destroy
					@notification.destroy
					redirect_to notifications_path
				end
			end
		else
			@match=Match.find_by(id: @notification.par.match_id)
			if(@match.pt!=nil)
				@match.pt.team = nil
				@notification.destroy
				redirect_to notifications_path
			elsif(@match.tt!=nil)
				if(@match.tt.team[0].capitano_id==@notification.receiver_id)
					@match.tt.team[0]=nil	
				elsif(@match.tt.team[1].capitano_id==@notification.receiver_id)
					@match.tt.team[1]=nil
				end
				@notification.destroy
				redirect_to notifications_path
			end
		end
	end

end
