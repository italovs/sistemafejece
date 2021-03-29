class SiteController < ApplicationController
	layout 'member', :except => [:profile, :my_channel, :my_library, :post, :serie]
	include ApplicationHelper
	skip_before_action :verify_authenticity_token
	before_action :check_if_user_is_director_or_is_admin, only: [:my_channel]

	def index
		direction_notification
		@categories = Category.all.select(:id, :name)
		@videos = Post.all.where(kind: 1)
		@posts = Post.all.where(kind: 0)
		@posts_and_videos = Post.all
		@post_categories = PostCategory.all
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
			if params[:profile_picture].present? && params[:profile_picture] != "undefined"
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
			if params[:new_email] == params[:repeat_email] && !(URI::MailTo::EMAIL_REGEXP =~ params[:repeat_email]).nil?
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
		@serie_categories = TvSerieCategory.all
		@categories = Category.all.select(:id, :name)
		series_and_videos		

		direction_notification
	end

	def new_serie
		tv_serie = TvSerie.new(name: params[:serie_name])
		if admin_signed_in?
			tv_serie.owner_id = nil
		else
			tv_serie.owner_id = current_member.junior_enterprise_id
		end
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
			kind: Post.kinds[:video]
		)
		post.banner_image.attach(params[:banner_image])	if params[:banner_image].present?
		post.poster_image.attach(params[:poster_image]) if params[:poster_image].present?

		categories = params[:categories].split(",")
		if admin_signed_in?
			post.owner_id = nil
		else
			post.owner_id = current_member.junior_enterprise_id
		end
		
		if post.save
			categories.each do |category|
				PostCategory.create(post_id: post.id, category_id: category.to_i)
			end
			series_and_videos
			render json: [msg: "Sucesso: Vídeo criado", series: @series, videos: @videos]
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
									WHERE "series"."owner_id" is NULL
									AND "categories"."name" = '
			else
				sql = 	'SELECT "series".*, "categories"."name" as "category_name" 
									FROM "tv_series" as "series"
									JOIN "tv_serie_categories" as "serie_category"
									ON "series"."id" = "serie_category"."tv_serie_id"
									JOIN "categories"
									ON "categories"."id" = "serie_category"."category_id"
									WHERE "series"."owner_id" = '
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

	def my_videos
		videos = Hash.new

		Category.all.each do |category|
			#reiniciando valores
			my_seasons = Hash.new
			my_series = Hash.new

			#processo
			if admin_signed_in?
				series = Category.find(category.id).tv_series.where('"tv_series"."owner_id" IS NULL')
			else
				series = Category.find(category.id).tv_series.where('"tv_series"."owner_id" = :member_id', member_id: current_member.id)
			end
			if series.count > 0
				series.each do |serie|
					seasons = serie.seasons
					#sempre há pelo menos uma season
					seasons.each do |season|
						season_posts = season.season_posts
						if season_posts.count > 0
							posts = season.posts.select(:name, :link)
							posts.each do |post|
								my_seasons[season.name] = posts
							end
						else
							my_seasons[season.name] = []
						end
					end
					my_series[serie.name] = my_seasons
				end
				videos[category.name] = my_series
			end
		end
		if videos.blank?
				render json: [msg: "Você ainda não possui séries"]
		else #nenhuma série
				render json: [series: videos]
		end
	end

	#retorna séries e informa quantidade de temporadas e vídeos em cada série
	#deve passar via ajax parâmetro da id da categoria
	def my_series_by_category
		#reiniciando valores
		hash_series = Hash.new
		
		if admin_signed_in?
			series = Category.find( params[:category_id] ).tv_series.where('"tv_series"."owner_id" IS NULL').order(:name)
		else
			series = Category.find( params[:category_id] ).tv_series.where('"tv_series"."owner_id" = :member_id', member_id: current_member.id).order(:name)
		end

		#processo
		seasons_quantity = 0
		videos_quantity = 0
		series.each do |serie|

			seasons = serie.seasons
			seasons_quantity = seasons.count
			#sempre há pelo menos uma season
			seasons.each do |season|
				season_posts = season.season_posts
				if season_posts.count > 1
					videos_quantity += seasons.posts.count
				elsif season_posts.count == 1
					videos_quantity += 1
				end
			end
			hash_series[serie.name] = [{id: serie.id, quantity: seasons.count}, videos_quantity]
		end

		if hash_series.blank?
				render json: [msg: "Você ainda não possui séries nessa categoria"]
		else #nenhuma série
				render json: [series: hash_series]
		end
	end

	#retorna temporadas de uma série e informa quantidade de vídeos em cada série
	#deve passar via ajax parâmetro da id da série
	def my_seasons_by_serie
		if params[:serie_id].present?
			serie = TvSerie.where(id: params[:serie_id])
			if serie.count == 1 && (admin_signed_in? && serie.first.owner_id.nil?) || (member_signed_in? && serie.first.owner_id == current_member.id)
				hash_seasons = Hash.new
				serie = serie.first
				seasons_quantity = serie.seasons.count
				serie.seasons.each do |season|
					videos_quantity = 0
					season_posts = season.season_posts
					if season_posts.count >= 1
						videos_quantity = seasons.posts.count
					end
					hash_seasons[serie.name] = [{id: season.id, seasons_quantity: seasons_quantity}, videos_quantity ]
				end

				if hash_seasons.blank?
					#isso nunca deveria acontecer, pois toda temporada tem pelo menos uma série... maaaaaas...
					render json: [msg: "Você ainda não possui Temporadas nessa Série"]
				else #nenhuma série
					render json: [series: hash_seasons]
				end
			else
				render json: [msg: "Série inválida para você"]
			end
		else
			render json: [msg: "Série inválida"]
		end
	end
	
	#retorna temporadas de uma série e informa quantidade de vídeos em cada série
	#deve passar via ajax parâmetro da id da série
	def my_posts_by_season
		if params[:season_id].present?
			season = Season.where(id: params[:serie_id]).first 
			posts = Season.where(id: params[:serie_id]).first.posts
			if (posts.count == 1 && posts.count > 0) && (admin_signed_in? && season.tv_serie.owner_id.nil?) || (member_signed_in? && season.tv_serie.owner_id == current_member.id)
				array_posts = []
				posts_quantity = posts.count
				posts.each do |post|
					array_posts << post.id
				end
				
				if hash_seasons.blank?
					render json: [msg: "Você ainda não possui Vídeos nessa Temporada"]
				else #nenhuma série
					render json: array_posts
				end
			else
				render json: [msg: "Temporada inválida para você"]
			end
		else
			render json: [msg: "Temporada inválida"]
		end
	end



	#retorna categorias e informa quantidade de séries, temporadas e vídeos em cada categoria
	def my_categories
		#reiniciando valores
		hash_categories = Hash.new

		Category.order(:name).each do |category|
			series_quantity = 0
			seasons_quantity = 0
			videos_quantity = 0

			#processo
			if admin_signed_in?
				series = Category.find(category.id).tv_series.where('"tv_series"."owner_id" IS NULL')
			else
				series = Category.find(category.id).tv_series.where('"tv_series"."owner_id" = :member_id', member_id: current_member.id)
			end
			series_quantity += series.count #
			if series_quantity > 0
				series.each do |serie|
					seasons = serie.seasons
					seasons_quantity += seasons.count #
					#sempre há pelo menos uma season
					seasons.each do |season|
						season_posts = season.season_posts
						if season_posts.count > 1
							videos_quantity += seasons.posts.count
						elsif season_posts.count == 1
							videos_quantity += 1
						end
					end
				end
			end
			if series_quantity > 0
				hash_categories[category.name] = [{id: category.id, quantity: series_quantity}, seasons_quantity, videos_quantity]
			end
		end

		if hash_categories.blank?
				render json: [msg: "Você ainda não possui séries"]
		else #nenhuma série
				render json: [categories: hash_categories]
		end
	end

	#POSTS
	def my_library
		@categories = Category.all.select(:id, :name)
		@post_categories = PostCategory.all
		if member_signed_in?
			@posts = Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 0)
		else
			@posts = Post.all.where(owner_id: nil, kind: 0)
		end	

		direction_notification
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
		categories = params[:categories].split(",")
		if admin_signed_in?
			post.owner_id = nil
		else
			post.owner_id = current_member.junior_enterprise_id
		end

		if post.save
			# if member_signed_in?
			# 	PostCategory.create(post_id: post.id, category_id: params[:category])
			# else
			# 	PostCategory.create(post_id: post.id, category_id: params[:category])
			# end
			categories.each do |category|
				PostCategory.create(post.id, category_id: category.to_i)
			end
			render json: [msg: "Sucesso: post criado"]
		else
			render json: [msg: "Erro: Falha ao criar post"]
		end
	end

	def my_posts
		categories = Category.all.pluck(:name)
		@@posts = Hash.new
		categories.each do |category|
			if admin_signed_in?
				sql = 'SELECT "posts".*, "post_categories"."id" AS "pc_id" FROM "posts" INNER JOIN "post_categories" ON "post_categories"."post_id" = "posts"."id" INNER JOIN "categories" ON "categories"."id" = "post_categories"."category_id" WHERE (post_categories.owner_id is null AND categories.name = \''
			else
				sql = 'SELECT "posts".*, "post_categories"."id" AS "pc_id" FROM "posts" INNER JOIN "post_categories" ON "post_categories"."post_id" = "posts"."id" INNER JOIN "categories" ON "categories"."id" = "post_categories"."category_id" WHERE (post_categories.owner_id = '
				sql += current_member.id
				sql += ' AND categories.name = \''
			end
			sql += category 
			sql += "')"
			@@posts[category] = ActiveRecord::Base.connection.execute(sql)
		end
		if @@posts != Hash.new
			render json: posts
		else
			render json: [msg: "Erro: Falha ao recuperar postagens"]
		end
	end

	def post
		@post = Post.find(params[:id])
		@posts = Post.all
		@ejs = JuniorEnterprise.all

		direction_notification
	end

	def serie
		@serie = TvSerie.find(params[:id])
		@videos = Post.all.where(kind: 1)
		@posts = Post.all.where(kind: 0)

		direction_notification
	end

	#requer id do post e nota
	def new_vote
		if admin_signed_in?
			vote = Vote.new(post_id: params[:post_id], owner: current_admin.id, admin: true, value: params[:value])
		else
			vote = Vote.new(post_id: params[:post_id], owner: current_member.id, admin: false, value: params[:value])
		end
		if vote.save
			if admin_signed_in?
				render json: [msg: "Sucesso: Sua nota foi salva", vote_information: vote.post.vote_information(current_admin, true)]
			else
				render json: [msg: "Sucesso: Sua nota foi salva", vote_information: vote.post.vote_information(current_member, false)]
			end
		else
			render json: [msg: "Erro: Falha ao salvar nota"]
		end
	end

	def search_for_video
		#params: name, category_id, serie_id, season_id, owner_id
		#OBS para pesquisar onwer com id nil (da FEJECE), passar valor de owner_id sendo 0
		query = ''
		unless params[:category_id].blank?
			query += '"categories"."id" = ' + params[:category_id].to_s
		end

		unless params[:serie_id].blank?
			if query != ''
				query += ' AND '
			end
			query += '"tv_series"."id" = ' + params[:serie_id].to_s
		end

		unless params[:owner_id].blank?
			if query != ''
				query += ' AND '
			end
			query += '"tv_series"."owner_id" '
			if params[:owner_id].to_s != "0"
				query += '= ' + params[:owner_id].to_s
			else
				query += 'IS NULL'
			end
		end

		unless params[:season_id].blank?
			if query != ''
				query += ' AND '
			end
			query += '"seasons"."id" = ' + params[:season_id].to_s
		end

		unless params[:name].blank?
			if query != ''
				query += ' AND '
			end
			query += 'UPPER("posts"."name") LIKE ' + "'%#{params[:name].upcase}%'"
		end

		videos = Post.where(kind: "video").left_joins(season_post: [season: [tv_serie: [tv_serie_category: [:category]]]]).where(query)
		
		if !videos.blank?
			render json: videos
		else
			render json: [msg: "Erro: Nenhum resultado encontrado"]
		end
	end

	def search_for_post
		#params: name, category_id, owner_id
		#OBS para pesquisar onwer com id nil (da FEJECE), passar valor de owner_id sendo 0
		query = ''
		unless params[:category_id].blank?
			query += '"categories"."id" = ' + params[:category_id].to_s
		end

		unless params[:owner_id].blank?
			if query != ''
				query += ' AND '
			end
			query += '"post_categories"."owner_id" '
			if params[:owner_id].to_s != "0"
				query += '= ' + params[:owner_id].to_s
			else
				query += 'IS NULL'
			end
		end

		unless params[:name].blank?
			if query != ''
				query += ' AND '
			end
			query += 'UPPER("posts"."name") LIKE ' + "'%#{params[:name].upcase}%'"
		end

		posts = Post.where(kind: "post").left_joins(post_category: [:category]).where(query)
		
		if !posts.blank?
			render json: posts
		else
			render json: [msg: "Erro: Nenhum resultado encontrado"]
		end
	end
	

	private
	#recupera rating, total de votos e voto de um usuário
	#pode ser chamado ao abrir um post
	#retorna um hash
	def get_vote_information(post, person, is_admin )
		post.vote_from_person( person, is_admin )
	end

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
			@tv_series = TvSerie.where(owner_id: nil).select(:id, :name)
		else
			@tv_series = TvSerie.where(owner_id: current_member.id).select(:id, :name)
		end
	end

	def direction_notification
		@flag = 0

		Member.all.each do |member|
			if member.validated == nil
				@flag = @flag + 1
			end
		end
	end

	def series_and_videos
		if member_signed_in?
			@series = TvSerie.all.where(owner_id: current_logged_user.junior_enterprise_id)
			@videos = Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 1)
		else
			@series = TvSerie.all.where(owner_id: nil)
			@videos = Post.all.where(owner_id: nil, kind: 1)
		end
	end
end
