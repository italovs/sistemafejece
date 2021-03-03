class SiteController < ApplicationController
	layout 'member', :except => :profile
	include ApplicationHelper
	skip_before_action :verify_authenticity_token
	before_action :check_if_user_is_director_or_is_admin, only: [:my_channel]

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
				if params[:profile_picture].present?
					@image = params[:profile_picture]
					
					if @image.content_type == "image/jpg" || @image.content_type == "image/png" || @image.content_type == "image/jpeg"
						if @person.profile_picture.attached?
							@person.profile_picture.purge()
							@person.profile_picture.attach(params[:profile_picture])
						else
							@person.profile_picture.attach(params[:profile_picture])
						end
					else
						render json: [msg: "formato de arquivo de imagem não suportado, somente jpg, png e jpeg são validos"] and return
					end
				end

				@person.name = params[:name] if params[:name].present?
				@person.about = params[:about] if params[:about].present?
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
	def my_channel #postagens de vídeo
		get_user_tv_series
		@categories = Category.all.select(:id, :name)
	end

	def new_serie
		tv_serie = TvSerie.new(name: params[:serie_name])
		if tv_serie.save
			TvSerieCategory.create(tv_serie: tv_serie, category_id: params[:category])
			render json: [msg: 'Nova série "' + params[:serie_name] + '" foi criada com sucesso!', tv_series: get_user_tv_series]
		else
			render json: [msg: "Erro: Deu ruim"]
		end	
	end

	def serie_seasons
		if admin_signed_in? || (member_signed_in? &&  current_member.validated?)
			seasons = TvSerie.find(params[:serie]).seasons.select(:id, :name)
			render json: [seasons: seasons]
		else
			render json: [msg: "Erro: Série inválida"]
		end
	end

	def new_video
		post = Post.new(
			name: params[:name],
			description: params[:description],
			link: params[:video_link],
			kind: Post.kinds[:video],
			poster_image: params[:poster_image],
			banner_image: params[:banner_image]
		)
		
		if post.save
			SeasonPost.create(post_id: post.id, season_id: params[:season])
			render json: [msg: "Sucesso: Vídeo criado"]
		else
			render json: [msg: "Erro: Falha ao criar vídeo"]
		end
	end

	def my_series
		series = Hash.new
		categories = Category.all.pluck(:name)
		categories.each do |category|
			if admin_signed_in?
				sql = 	'SELECT "series".*, "categories"."name" as "category_name" 
									FROM "tv_series" as "series"
									JOIN "tv_serie_categories" as "serie_category"
									ON "series"."id" = "serie_category"."tv_serie_id"
									JOIN "categories"
									ON "categories"."id" = "serie_category"."category_id"
									WHERE "series"."is_admin" is true
									AND "categories"."name" = '
			else
				sql = 	'SELECT "series".*, "categories"."name" as "category_name" 
									FROM "tv_series" as "series"
									JOIN "tv_serie_categories" as "serie_category"
									ON "series"."id" = "serie_category"."tv_serie_id"
									JOIN "categories"
									ON "categories"."id" = "serie_category"."category_id"
									WHERE "series"."is_admin" is false
									AND "series"."owner_id" = '
				sql +=		"#{current_member.id} "
				sql +=		'AND "categories"."name" = '
			end
			sql += "'#{category}'"
			series[category] = ActiveRecord::Base.connection.execute(sql)
		end
		if series != Hash.new
			render json: series
		else
			render json: [msg: "Erro: Falha ao recuperar postagens"]
		end
	end

	def video
		@post = SeasonPost.find(params[:id]).post
	end

	#POSTS
	def my_library
		@categories = Category.all.select(:id, :name)
	end

	def new_post
		post = Post.new(
			name: params[:name],
			description: params[:description],
			link: params[:link],
			kind: Post.kinds[:post],
			poster_image: params[:poster_image],
			banner_image: params[:banner_image]
		)

		if post.save
			if member_signed_in?
				PostCategory.create(post_id: post.id, category_id: params[:category], is_admin: false, owner_id: current_member.id)
			else
				PostCategory.create(post_id: post.id, category_id: params[:category], is_admin: true)
			end
				render json: [msg: "Sucesso: post criado"]
		else
			render json: [msg: "Erro: Falha ao criar post"]
		end
	end

	def my_posts
		categories = Category.all.pluck(:name)
		posts = Hash.new
		categories.each do |category|
			if admin_signed_in?
				sql = 'SELECT "posts".*, "post_categories"."id" AS "pc_id" FROM "posts" INNER JOIN "post_categories" ON "post_categories"."post_id" = "posts"."id" INNER JOIN "categories" ON "categories"."id" = "post_categories"."category_id" WHERE (post_categories.owner_id is null AND post_categories.is_admin is true AND categories.name = \''
			else
				sql = 'SELECT "posts".*, "post_categories"."id" AS "pc_id" FROM "posts" INNER JOIN "post_categories" ON "post_categories"."post_id" = "posts"."id" INNER JOIN "categories" ON "categories"."id" = "post_categories"."category_id" WHERE (post_categories.owner_id = '
				sql += current_member.id
				sql += ' AND post_categories.is_admin is false AND categories.name = \''
			end
			sql += category 
			sql += "')"
			posts[category] = ActiveRecord::Base.connection.execute(sql)
		end
		if posts != Hash.new
			render json: posts
		else
			render json: [msg: "Erro: Falha ao recuperar postagens"]
		end
	end

	def post
		@post = PostCategory.find(params[:id]).post
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
		if admin_signed_in?
			@tv_series = TvSerie.where(is_admin: true).select(:id, :name)
		else
			@tv_series = TvSerie.where(owner_id: current_member.id, is_admin: false).select(:id, :name)
		end
	end
end
