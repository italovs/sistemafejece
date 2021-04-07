class SiteController < ApplicationController
	layout 'member', except: [:profile, :my_channel, :my_library, :post, :serie]
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
		@ejs = JuniorEnterprise.all.map { |ej| [ej.name, ej.id] }
		@profile = current_member
		@positions = Member.positions.map { |k, _v| [k.capitalize, k] }
		@directories = [['Membro', false], ['Diretoria', true], ['Solicitar Dirertoria', '']]
	end

	def request_to_become_a_director
		@member = current_member
		ActiveRecord::Base.transaction do
			@member.validated = nil
			@member.save
			flash[:notice] = 'Diretoria Solicitada'
			render json: [msg: 'Valeu, meu consagrado!',
										member: @member,
										junior_enterprise: @member.junior_enterprise.name]
		end
	rescue ActiveRecord::RecordInvalid
		flash[:alert] = "falha ao solicitar diretoria + #{@member.errors}"
		render json: [msg: "Erro:  #{@member.errors}"]
	end

	def change_password
		@person = if member_signed_in?
								current_member
							else
								current_admin
							end

		if @person.valid_password? params[:old_password]
			if params[:new_password] == params[:confirmation_password]
				@person.password = params[:new_password]
				if @person.save
					flash[:notice] = 'Senha alterada com sucesso'
					if member_signed_in?
						render json: [msg: 'Sucesso: Deu bom, meu bacano',
													person: person_information(@person),
													junior_enterprise: @person.junior_enterprise.name]
					else
						render json: [msg: 'Sucesso: Deu bom, meu bacano', person: person_information(@person)]
					end
				else
					flash[:alert] = 'falha ao salvar nova senha, tente novamente'
					if member_signed_in?
						render json: [msg: 'Erro: Falha em salvar nova senha',
													person: person_information(@person),
													junior_enterprise: @person.junior_enterprise.name]
					else
						render json: [msg: 'Erro: Falha em salvar nova senha',
													person: person_information(@person)]
					end
				end
			else
				flash[:alert] = 'Erro: Campos de nova senha não são iguais'
				if member_signed_in?
					render json: [msg: 'Erro: Campos de nova senha não são iguais',
												person: person_information(@person),
												junior_enterprise: @person.junior_enterprise.name]
				else
					render json: [msg: 'Erro: Campos de nova senha não são iguais',
												person: person_information(@person)]
				end
			end
		else
			flash[:alert] = 'Erro: Senha antiga inválida'
			if member_signed_in?
				render json: [msg: 'Erro: Senha antiga inválida',
											person: person_information(@person),
											junior_enterprise: @person.junior_enterprise.name]
			else
				render json: [msg: 'Erro: Senha antiga inválida',
											person: person_information(@person)]
			end
		end
	end

	def change_information
		@person = if member_signed_in?
								current_member
							else
								current_admin
							end

		if @person.valid_password? params[:confirmation_password]
			if params[:profile_picture].present? && params[:profile_picture] != 'undefined'
				@image = params[:profile_picture]
				
				if ['image/jpg', 'image/png', 'image/jpeg'].include?(@image.content_type)
					@person.profile_picture.purge if @person.profile_picture.attached?
					@person.profile_picture.attach(params[:profile_picture])
				else
					render json: [msg: 'formato de arquivo de imagem não suportado,
						somente jpg, png e jpeg são validos'] and return
				end
			end

			@person.name = params[:name] if params[:name].present?
			@person.about = params[:about] if params[:about].present?
			# apenas membros
			if member_signed_in?
				@person.position = params[:position] if params[:position].present?
				if params[:junior_enterprise].present?
					@person.junior_enterprise_id = params[:junior_enterprise]
				end
			end
			if @person.save
				flash[:notice] = 'Informações alteradas com sucesso'
				if member_signed_in?
					render json: [msg: 'Sucesso: Deu bom, meu bacano',
												person: person_information(@person),
												junior_enterprise: @person.junior_enterprise.name]
				else
					render json: [msg: 'Sucesso: Deu bom, meu bacano',
												person: person_information(@person)]
				end
			else
				flash[:alert] = 'Erro: Falha em salvar novo e-mail'
				if member_signed_in?
					render json: [msg: 'Erro: Falha em salvar novo e-mail',
												person: person_information(@person),
												junior_enterprise: @person.junior_enterprise.name]
				else
					render json: [msg: 'Erro: Falha em salvar novo e-mail',
												person: person_information(@person)]
				end
			end
		else
			flash[:alert] = 'Erro: Senha inválida'
			if member_signed_in?
				render json: [msg: 'Erro: Senha inválida',
											person: person_information(@person),
											junior_enterprise: @person.junior_enterprise.name]
			else
				render json: [msg: 'Erro: Senha inválida',
											person: person_information(@person)]
			end
		end
	end

	def change_mail
		@person = if member_signed_in?
								current_member
							else
								current_admin
							end

		if @person.valid_password? params[:confirmation_password]
			if params[:new_email] == params[:repeat_email] &&
				!(URI::MailTo::EMAIL_REGEXP =~ params[:repeat_email]).nil?
				@person.email = params[:new_email]
				if @person.save
					flash[:notice] = 'Email alterado com sucesso'
					if member_signed_in?
						render json: [msg: 'Sucesso: Deu bom, meu bacano',
													person: person_information(@person),
													junior_enterprise: @person.junior_enterprise.name]
					else
						render json: [msg: 'Sucesso: Deu bom, meu bacano',
													person: person_information(@person)]
					end
				else
					flash[:alert] = 'Erro: Falha em salvar novo e-mail'
					if member_signed_in?
						render json: [msg: 'Erro: Falha em salvar novo e-mail',
													person: person_information(@person),
													junior_enterprise: @person.junior_enterprise.name]
					else
						render json: [msg: 'Erro: Falha em salvar novo e-mail',
													person: person_information(@person)]
					end
				end
			else
				flash[:alert] = 'Erro: Campos de novo e-mail não são iguais'
				if member_signed_in?
					render json: [msg: 'Erro: Campos de novo e-mail não são iguais',
												person: person_information(@person),
												junior_enterprise: @person.junior_enterprise.name]
				else
					render json: [msg: 'Erro: Campos de novo e-mail não são iguais',
												person: person_information(@person)]
				end
			end
		else
			flash[:alert] = 'Erro: Senha inválida'
			if member_signed_in?
				render json: [msg: 'Erro: Senha inválida',
											person: person_information(@person),
											junior_enterprise: @person.junior_enterprise.name]
			else
				render json: [msg: 'Erro: Senha inválida', person: person_information(@person)]
			end
		end
	end

	# POSTS VIDEO
	# postagens de video
	def my_channel
		user_tv_series
		@videos = Post.all.where(kind: 1)
		@serie_categories = TvSerieCategory.all
		@categories = Category.all.select(:id, :name)
		series_and_videos

		direction_notification
	end

	def new_serie
		tv_serie = TvSerie.new(name: params[:serie_name])
		tv_serie.owner_id = if admin_signed_in?
													nil
												else
													current_member.junior_enterprise_id
												end
		if tv_serie.save
			TvSerieCategory.create(tv_serie: tv_serie, category_id: params[:category])
			render json: [msg: "Nova trilha #{params[:serie_name]} foi criada com sucesso!",
										tv_series: user_tv_series]

			flash[:notice] = "Nova trilha  #{params[:serie_name]} foi criada com sucesso"
		else
			flash[:alert] = 'Ocorreu um erro ao salvar nova trilha'
			render json: [msg: 'Erro: Deu ruim']
		end
	end

	def serie_seasons
		if admin_signed_in? || (member_signed_in? && current_member.validated?)
			seasons = TvSerie.find(params[:serie]).seasons.select(:id, :name)
			render json: [seasons: seasons]
		else
			render json: [msg: 'Erro: Série inválida']
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

		categories = params[:categories].split(',')
		post.owner_id = if admin_signed_in?
											nil
										else
											current_member.junior_enterprise_id
										end

		if post.save
			categories.each do |category|
				PostCategory.create(post_id: post.id, category_id: category.to_i)
			end
			series_and_videos
			flash[:notice] = 'Vídeo criado com sucesso'
			render json: [msg: 'Sucesso: Vídeo criado', series: @series, videos: @videos]
		else
			flash[:alert] = 'Erro: Falha ao criar vídeo, tente novamente.'
			render json: [msg: 'Erro: Falha ao criar vídeo']
		end
	end

	def my_series
		series = {}
		categories = Category.all.pluck(:name)
		categories.each do |category|
			if admin_signed_in?
				sql =	'SELECT "series".*, "categories"."name" as "category_name"
									FROM "tv_series" as "series"
									JOIN "tv_serie_categories" as "serie_category"
									ON "series"."id" = "serie_category"."tv_serie_id"
									JOIN "categories"
									ON "categories"."id" = "serie_category"."category_id"
									WHERE "series"."owner_id" is NULL
									AND "categories"."name" = '
			else
				sql =	'SELECT "series".*, "categories"."name" as "category_name"
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
		if series != ({})
			render json: series
		else
			flash[:alert] = 'Erro: Falha ao recuperar postagens'
			render json: [msg: 'Erro: Falha ao recuperar postagens']
		end
	end

	def video
		@post = SeasonPost.find(params[:id]).post
	end

	def my_videos
		videos = {}

		Category.all.each do |category|
			# reiniciando valores
			my_seasons = {}
			my_series = {}

			# processo
			series = 	if admin_signed_in?
									Category.find(category.id).tv_series.where('"tv_series"."owner_id" IS NULL')
								else
									Category.find(category.id)
										.tv_series.where('"tv_series"."owner_id" = :member_id',
										member_id: current_member.id)
								end

			next unless series.count.positive?

			series.each do |serie|
				seasons = serie.seasons
				# sempre ha pelo menos uma season
				seasons.each do |season|
					season_posts = season.season_posts
					if season_posts.count.positive?
						posts = season.posts.select(:name, :link)
						posts.each do |_post|
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
		if videos.blank?
			render json: [msg: 'Você ainda não possui séries']
		else # nenhuma serie
			render json: [series: videos]
		end
	end

	# retorna series e informa quantidade de temporadas e videos em cada serie
	# deve passar via ajax parametro da id da categoria
	def my_series_by_category
		# reiniciando valores
		hash_series = {}

		series = if admin_signed_in?
							 Category.find(params[:category_id])
								 .tv_series
								 .where('"tv_series"."owner_id" IS NULL')
								 .order(:name)
						 else
							 Category.find(params[:category_id])
								 .tv_series
								 .where('"tv_series"."owner_id" = :member_id',
									 member_id: current_member.id).order(:name)
						 end

		# processo
		seasons_quantity = 0
		videos_quantity = 0
		series.each do |serie|
			seasons = serie.seasons
			seasons_quantity = seasons.count
			# sempre ha pelo menos uma season
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
			render json: [msg: 'Você ainda não possui séries nessa categoria']
		else # nenhuma serie
			render json: [series: hash_series]
		end
	end

	# retorna temporadas de uma serie e informa quantidade de videos em cada serie
	# deve passar via ajax parametro da id da serie
	def my_seasons_by_serie
		if params[:serie_id].present?
			serie = TvSerie.where(id: params[:serie_id])
			if serie.count == 1 &&
				 (admin_signed_in? && serie.first.owner_id.nil?) ||
				 (member_signed_in? && serie.first.owner_id == current_member.id)
				hash_seasons = {}
				serie = serie.first
				seasons_quantity = serie.seasons.count
				serie.seasons.each do |season|
					videos_quantity = 0
					season_posts = season.season_posts
					videos_quantity = seasons.posts.count if season_posts.count >= 1
					hash_seasons[serie.name] = [{	id: season.id,
																				seasons_quantity: seasons_quantity}, videos_quantity]
				end

				if hash_seasons.blank?
					# isso nunca deveria acontecer, pois toda temporada tem pelo menos uma serie... maaaaaas..
					render json: [msg: 'Você ainda não possui Temporadas nessa Série']
				else # nenhuma serie
					render json: [series: hash_seasons]
				end
			else
				render json: [msg: 'Série inválida para você']
			end
		else
			flash[:alert] = 'Trilha inválida'
			render json: [msg: 'Série inválida']
		end
	end

	# retorna temporadas de uma serie e informa quantidade de videos em cada serie
	# deve passar via ajax parametro da id da serie
	def my_posts_by_season
		if params[:season_id].present?
			season = Season.where(id: params[:serie_id]).first
			posts = Season.where(id: params[:serie_id]).first.posts
			if (posts.count == 1 && posts.count.positive?) &&
				 (admin_signed_in? && season.tv_serie.owner_id.nil?) ||
				 (member_signed_in? && season.tv_serie.owner_id == current_member.id)
				array_posts = []
				posts.each do |post|
					array_posts << post.id
				end

				if hash_seasons.blank?
					render json: [msg: 'Você ainda não possui Vídeos nessa Temporada']
				else # nenhuma serie
					render json: array_posts
				end
			else
				render json: [msg: 'Temporada inválida para você']
			end
		else
			flash[:alert] = 'Temporada inválida'
			render json: [msg: 'Temporada inválida']
		end
	end

	# retorna categorias e informa quantidade de series, temporadas e videos em cada categoria
	def my_categories
		# reiniciando valores
		hash_categories = {}

		Category.order(:name).each do |category|
			series_quantity = 0
			seasons_quantity = 0
			videos_quantity = 0

			# processo
			series = if admin_signed_in?
								 Category.find(category.id).tv_series.where('"tv_series"."owner_id" IS NULL')
							 else
								 Category.find(category.id)
									 .tv_series
									 .where('"tv_series"."owner_id" = :member_id',
										 member_id: current_member.id)
							 end
			series_quantity += series.count
			if series_quantity.positive?
				series.each do |serie|
					seasons = serie.seasons
					seasons_quantity += seasons.count #
					# sempre ha pelo menos uma season
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
			next unless series_quantity.positive?

			hash_categories[category.name] = [{id: category.id,
																				quantity: series_quantity},
																				seasons_quantity,
																				videos_quantity]
		end

		if hash_categories.blank?
			render json: [msg: 'Você ainda não possui séries']
		else # nenhuma serie
			render json: [categories: hash_categories]
		end
	end

	# POSTS
	def my_library
		@videos = Post.all.where(kind: 1)
		@categories = Category.all.select(:id, :name)
		@post_categories = PostCategory.all
		@posts = if member_signed_in?
							Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 0)
						else
							Post.all.where(owner_id: nil, kind: 0)
						end

		direction_notification
	end

	def new_post
		file_post = Post.new(
			name: params[:name],
			description: params[:description],
			link: params[:link],
			kind: Post.kinds[:post]
		)
		if params[:poster_image].present? && params[:poster_image] != 'undefined'
			file_post.poster_image = params[:poster_image]
		end
		if params[:banner_image].present? && params[:banner_image] != 'undefined'
			file_post.banner_image = params[:banner_image]
		end
		categories = params[:categories].split(',')
		file_post.owner_id = if admin_signed_in?
													nil
												else
													current_member.junior_enterprise_id
												end
		if file_post.save
			categories.each do |category|
				PostCategory.create(file_post.id, category_id: category.to_i)
			end
			flash[:notice] = 'Sucesso: post criado'
			render json: [msg: 'Sucesso: post criado']
		else
			flash[:alert] = 'Erro: Falha ao criar post'
			render json: [msg: 'Erro: Falha ao criar post']
		end
	end

	def my_posts
		categories = Category.all.pluck(:name)
		@posts = {}
		categories.each do |category|
			if admin_signed_in?
				sql = 'SELECT "posts".*, "post_categories"."id"
		AS "pc_id"
		FROM "posts"
		INNER JOIN "post_categories"
		ON "post_categories"."post_id" = "posts"."id"
		INNER JOIN "categories"
		ON "categories"."id" = "post_categories"."category_id"
		WHERE (post_categories.owner_id is null AND categories.name = \''
			else
				sql = 'SELECT "posts".*, "post_categories"."id"
		AS "pc_id"
		FROM "posts"
		INNER JOIN "post_categories"
		ON "post_categories"."post_id" = "posts"."id"
		INNER JOIN "categories"
		ON "categories"."id" = "post_categories"."category_id"
		WHERE (post_categories.owner_id = '
        sql += current_member.id
        sql += ' AND categories.name = \''
      end
      sql += category
      sql += "')"
      @posts[category] = ActiveRecord::Base.connection.execute(sql)
    end
    if @posts != ({})
      render json: posts
    else
      flash[:alert] = 'Erro: Falha ao recuperar postagens'
      render json: [msg: 'Erro: Falha ao recuperar postagens']
    end
  end

  def post
    @videos = Post.all.where(kind: 1)
    @post = Post.find(params[:id])
    @posts = Post.all
    @ejs = JuniorEnterprise.all
	  @votes = Vote.all

		direction_notification
	end

  def post_information
    @post = Post.find(params[:id])

    post_categories = PostCategory.where(post_id: @post.id)

    categories = []

    post_categories.each do |post_category|
      categories << post_category.category
    end

    render json: [post_id: @post.id,
                  post_image: @post.poster_image,
                  banner_image: @post.banner_image,
                  post_name: @post.name,
                  post_description: @post.description,
                  post_link: @post.link,
                  post_categories: categories]
  end

	def serie
		@serie = TvSerie.find(params[:id])
		@videos = Post.all.where(kind: 1)
		@posts = Post.all.where(kind: 0)

		direction_notification
	end

	# requer id do post e nota
	def new_vote
		vote = if admin_signed_in?
						Vote.new(post_id: params[:post_id],
											owner: current_admin.id,
											admin: true,
											value: params[:value])
					else
						Vote.new(post_id: params[:post_id],
											owner: current_member.id,
											admin: false,
											value: params[:value])
					end
		if vote.save
			flash[:notice] = 'Sucesso: Sua nota foi salva'
			if admin_signed_in?
				render json: [msg: 'Sucesso: Sua nota foi salva',
											vote_information: vote.post.vote_information(current_admin, true)]
			else
				render json: [msg: 'Sucesso: Sua nota foi salva',
											vote_information: vote.post.vote_information(current_member, false)]
			end
		else
			flash[:alert] = 'Erro: Falha ao salvar nota'
			render json: [msg: 'Erro: Falha ao salvar nota']
		end
	end

	def search_for_video
		# params: name, category_id, serie_id, season_id, owner_id
		# OBS para pesquisar onwer com id nil (da FEJECE), passar valor de owner_id sendo 0
		query = ''
		query += "'categories'.'id' = #{params[:category_id]}" if params[:category_id].present?

		if params[:serie_id].present?
			query += ' AND ' if query != ''
			query += "'tv_series'.'id' = #{params[:serie_id]}"
		end

		if params[:owner_id].present?
			query += ' AND ' if query != ''
			query += '"tv_series"."owner_id" '
			query += if params[:owner_id].to_s != '0'
								"= #{params[:owner_id]}"
							else
								'IS NULL'
							end
		end

		if params[:season_id].present?
			query += ' AND ' if query != ''
			query += "'seasons'.'id' = #{params[:season_id]}"
		end

		if params[:name].present?
			query += ' AND ' if query != ''
			query += "UPPER('posts'.'name') LIKE %#{params[:name].upcase}%"
		end

		videos = Post.where(kind: 'video')
			.left_joins(season_post: [season: [tv_serie: [tv_serie_category: [:category]]]])
			.where(query)

		if videos.present?
			render json: videos
		else
			render json: [msg: 'Erro: Nenhum resultado encontrado']
		end
	end

	def search_for_post
		# params: name, category_id, owner_id
		# OBS para pesquisar onwer com id nil (da FEJECE), passar valor de owner_id sendo 0
		query = ''
		query += '"categories"."id" = ' + params[:category_id].to_s if params[:category_id].present?

		if params[:owner_id].present?
			query += ' AND ' if query != ''
			query += '"post_categories"."owner_id" '
			query += if params[:owner_id].to_s != '0'
								'= ' + params[:owner_id].to_s
							else
								'IS NULL'
							end
		end

		if params[:name].present?
			query += ' AND ' if query != ''
			query += 'UPPER("posts"."name") LIKE ' + "'%#{params[:name].upcase}%'"
		end

		posts = Post.where(kind: 'post').left_joins(post_category: [:category]).where(query)

		if posts.present?
			render json: posts
		else
			render json: [msg: 'Erro: Nenhum resultado encontrado']
		end
	end

	def update_video
		# params de entrada: name, description, link, video_id
		video = Post.find_by(id: params[:video_id])
		if !video.video? || video.nil?
			# id invalida ou tipo invalido
			render json: [msg: 'Erro: Nenhum resultado encontrado']
		elsif video.video? || !video.nil?
			if !((admin_signed_in? && video.owner_id.nil?) ||
					(member_signed_in? && (video.owner_id == current_member.id)))
				# video de outro dono
				render json: [msg: 'Erro: Erro ao encontrar o vídeo']
			else
				video.name = params[:name] unless params[:name].nil?
				video.description = params[:description] unless params[:description].nil?
				video.link = params[:link] unless params[:link].nil?
				if video.save
					# sucesso
					flash[:notice] = 'Sucesso: Vídeo foi atualizado'
					render json: [msg: 'Sucesso: Vídeo foi atualizado', video: video]
				else
					# falha
					flash[:alert] = 'Erro: Falha ao atualizad o vídeo'
					render json: [msg: 'Erro: Falha ao atualizad o vídeo']
				end
			end
		end
	end

	def update_post
		# params de entrada: name, description, link, post_id
		post = Post.find_by(id: params[:post_id])
		if !post.post? || post.nil?
			# id invalida ou tipo invalido
			render json: [msg: 'Erro: Nenhum resultado encontrado']
		elsif post.post? || !post.nil?
			if !verify_post_onwership( post )
				# post de outro dono
				render json: [msg: 'Erro: Erro ao encontrar o post']
			else
				post.name = params[:name] unless params[:name].nil?
				post.description = params[:description] unless params[:description].nil?
				post.link = params[:link] unless params[:link].nil?
				if post.save
					# sucesso
					flash[:notice] = 'Sucesso: Post foi atualizado'
					render json: [msg: 'Sucesso: Post foi atualizado', post: post]
				else
					# falha
					flash[:alert] = 'Erro: Falha ao atualizad o post'
					render json: [msg: 'Erro: Falha ao atualizad o post']
				end
			end
		end
	end

	def view_counter_update
		post = Post.find(params[:id])
		post.views += 1
		post.save
	end

	def delete_post
		post = Post.find_by(id: params[:id])
		if post.nil?
			render json: [msg: 'Erro: Post ou Vídeo inválido']
		else
			if verify_post_onwership( post ) || admin_signed_in?
				#verificar aqui se o post está em alguma série

				post.post_category.each do |post_category|
					post_category.delete
				end
				post.poster_image.purge
				post.banner_image.purge
				post.delete
				render json: [msg: 'Publicação deletada com sucesso']
			else
				render json: [msg: 'Erro: Você não pode excluir esse post']
			end
		end
	end

	private

	# recupera rating, total de votos e voto de um usuario
	# pode ser chamado ao abrir um post
	# retorna um hash
	def get_vote_information(post, person, is_admin)
		post.vote_from_person(person, is_admin)
	end

	def person_information(person)
		if admin_signed_in?
			{	name: person.name,
				about: person.about,
				email: person.email }
		else
			{	name: person.name,
				about: person.about,
				email: person.email,
				position: person.position.capitalize,
				validated: person.validated }
		end
	end

	def check_if_user_is_director_or_is_admin
		if member_signed_in? && !current_member.validated?
			redirect_back(fallback_location: member_root_path)
		end
	end

	def user_tv_series
		@tv_series = if admin_signed_in?
									TvSerie.where(owner_id: nil).select(:id, :name)
								else
									TvSerie.where(owner_id: current_member.id).select(:id, :name)
								end
	end

	def direction_notification
		@flag = 0

		Member.all.each do |member|
			@flag += 1 if member.validated.nil?
		end
	end

	def series_and_videos( kind = nil )
		if member_signed_in?
			@series = TvSerie.all.where(owner_id: current_logged_user.junior_enterprise_id)
			if kind.nil?
				@videos = Post.all.where(owner_id: current_logged_user.junior_enterprise_id)
			elsif kind == 1
				@videos = Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 1)
			elsif kind == 2
				@videos = Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 2)
			end
		else
			@series = TvSerie.all.where(owner_id: nil)
			if kind.nil?
				@videos = Post.all.where(owner_id: nil)
			elsif kind == 1
				@videos = Post.all.where(owner_id: nil, kind: 1)
			elsif kind == 2
				@videos = Post.all.where(owner_id: nil, kind: 2)
			end
		end
	end

	def verify_post_onwership( post )
		if admin_signed_in?
			post.owner_id.nil?
		elsif current_member.validated?
			post.owner_id == current_member.junior_enterprise_id
		else
			false
		end
	end

end
