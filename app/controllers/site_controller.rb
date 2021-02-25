class SiteController < ApplicationController
	layout "member", :except => :profile
	include ApplicationHelper
	skip_before_action :verify_authenticity_token
	before_action :check_if_user_is_director_or_is_admin, only: [:video_channel]

	def index
	end

	def profile
		@ejs = JuniorEnterprise.all.map { |ej| [ ej.name,  ej.id, ]}
		@profile = current_member
		@positions = Member.positions.map { |k,v| [k.capitalize, k] }
		@directories = [ ["Membro", false], ["Diretoria", true], ["Solicitar Dirertoria", ""] ]
	end

	def request_to_become_a_director
		@member = current_member
		ActiveRecord::Base.transaction do
			@member.validated = nil
			@member.save
			render json: [msg: "Valeu, meu consagrado!", member: @member, junior_enterprise: @member.junior_enterprise.name]
		end

		rescue  ActiveRecord::RecordInvalid
			render json: [msg: "Erro: "+	@member.errors ]
	end

	def change_password
		if member_signed_in?
			@person = current_member
		else
			@person = current_admin
		end

		if @person.valid_password? params[:old_password]
			if params[:new_password] == params[:confirmation_password]
				@person.password = params[:new_password]
				if @person.save
					if member_signed_in?
						render json: [msg: "Sucesso: Deu bom, meu bacano", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name]
					else
						render json: [msg: "Sucesso: Deu bom, meu bacano", person: person_information( @person )]
					end
				else
					if member_signed_in?
						render json: [msg: "Erro: Falha em salvar nova senha", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name]
					else
						render json: [msg: "Erro: Falha em salvar nova senha", person: person_information( @person )]
					end
				end
			else
				if member_signed_in?
					render json: [msg: "Erro: Campos de nova senha não são iguais", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name]
				else
					render json: [msg: "Erro: Campos de nova senha não são iguais", person: person_information( @person )]
				end
			end
		else
			if member_signed_in?
				render json: [msg: "Erro: Senha antiga inválida", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name ]
			else
				render json: [msg: "Erro: Senha antiga inválida", person: person_information( @person )]
			end
		end
	end

	def change_information
		if member_signed_in?
			@person = current_member
		else
			@person = current_admin
		end
		
		if @person.valid_password? params[:confirmation_password]
			if params[:new_email] == params[:repeat_email]
				@person.name = params[:name] if params[:name].present?
				@person.about = params[:about] if params[:about].present?
				if params[:profile_picture].present?
					if @person.profile_picture.present?
						temp= @person.profile_picture
						@person.profile_picture.purge()
						if @person.profile_picture.attach(params[:profile_picture])
						else
							@person.profile_picture.attach(temp)
						end
					end
					@person.profile_picture.attach(params[:profile_picture])
				end
				#apenas membros
				if member_signed_in?
					@person.position = params[:position] if params[:position].present?
					@person.junior_enterprise_id = params[:junior_enterprise] if params[:junior_enterprise].present?
				end
				if @person.save
					if member_signed_in?
						render json: [msg: "Sucesso: Deu bom, meu bacano", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name]
					else
						render json: [msg: "Sucesso: Deu bom, meu bacano", person: person_information( @person )]
					end
				else
					if member_signed_in?
						render json: [msg: "Erro: Falha em salvar novo e-mail", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name]
					else
						render json: [msg: "Erro: Falha em salvar novo e-mail", person: person_information( @person )]
					end
				end
			else
				if member_signed_in?
					render json: [msg: "Erro: Campos de novo e-mail não são iguais", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name]
				else
					render json: [msg: "Erro: Campos de novo e-mail não são iguais", person: person_information( @person )]
				end
			end
		else
			if member_signed_in?
				render json: [msg: "Erro: Senha inválida", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name ]
			else
				render json: [msg: "Erro: Senha inválida", person: person_information( @person )]
			end
		end
	end
	
	def change_mail
		if member_signed_in?
			@person = current_member
		else
			@person = current_admin
		end

		if @person.valid_password? params[:confirmation_password]			
			if params[:new_email] == params[:repeat_email]
				@person.email = params[:new_email]
				if @person.save
					if member_signed_in?
						render json: [msg: "Sucesso: Deu bom, meu bacano", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name]
					else
						render json: [msg: "Sucesso: Deu bom, meu bacano", person: person_information( @person )]
					end
				else
					if member_signed_in?
						render json: [msg: "Erro: Falha em salvar novo e-mail", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name]
					else
						render json: [msg: "Erro: Falha em salvar novo e-mail", person: person_information( @person )]
					end
				end
			else
				if member_signed_in?
					render json: [msg: "Erro: Campos de novo e-mail não são iguais", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name]
				else
					render json: [msg: "Erro: Campos de novo e-mail não são iguais", person: person_information( @person )]
				end
			end
		else
			if member_signed_in?
				render json: [msg: "Erro: Senha inválida", person: person_information( @person ), junior_enterprise: @person.junior_enterprise.name ]
			else
				render json: [msg: "Erro: Senha inválida", person: person_information( @person )]
			end
		end
	end

	#POSTS VIDEO
	def video_channel #postagens de vídeo
		get_user_tv_series
		@categories = Category.all.select(:id, :name)
	end

	def new_serie
		tv_serie = TvSerie.new(name: params[:serie_name], owner_id: admin_signed_in? ? current_admin.id : current_member.id , is_admin: admin_signed_in? )
		if tv_serie.save
			TvSerieCategory.create(tv_serie: tv_serie, category_id: params[:category])
			render json: [msg: 'Nova série "' + params[:serie_name] + '" foi criada com sucesso!', tv_series: get_user_tv_series]
		else
			render json: [msg: "Erro: Deu ruim"]
		end	
	end

	def get_serie_seasons

	end

	private
	
	def person_information( person )
		admin_signed_in? ? {name: person.name, about: person.about, email: person.email } : {name: person.name, about: person.about, email: person.email, position: person.position.capitalize, validated: person.validated }  
	end

	def check_if_user_is_director_or_is_admin
		if member_signed_in?
			unless current_member.validated?
				redirect_back(fallback_location: member_root_path)
			end
		end
	end

	def get_user_tv_series
		@tv_series = TvSerie.where(owner_id: admin_signed_in? ? current_admin.id : current_member.id , is_admin: admin_signed_in?).select(:id, :name)
	end
end
