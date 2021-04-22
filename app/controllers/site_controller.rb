class SiteController < ApplicationController
  layout 'member', except: [:profile, :my_channel, :my_library, :my_trails, :post, :serie, :all_content, :all_videos, :all_posts, :all_series]
  include ApplicationHelper
  skip_before_action :verify_authenticity_token
  before_action :check_if_user_is_director_or_is_admin, only: [:my_channel, :my_library, :my_trails]

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

  def all_content
    # @all = []
    # Post.all.each do |post|
    #   @all << post
    # end

    # TvSerie.all.each do |serie|
    #   @all << serie
    # end

    @ejs = JuniorEnterprise.all
    @categories = Category.all
    
    @q = Post.all.ransack(params[:q]) 
    @all_content = @q.result(distinct: true)

    direction_notification
  end

  def all_videos
    # @custom_ejs = []
    # @custom_ejs << ({id: nil, name: "Todas as EJs"})
    # JuniorEnterprise.all.each do |ej|
    #   @custom_ejs << ({id: ej.id, name: ej.name})
    # end
    #@custom_ejs << ({id: nil, name: "FEJECE"})
    
    @ejs = JuniorEnterprise.all
    @categories = Category.all
    
    @q = Post.where(kind: 1).ransack(params[:q])
    @videos = @q.result(distinct: true)

    direction_notification
  end

  def all_posts
    @ejs = JuniorEnterprise.all
    @categories = Category.all

    @q = Post.all.where(kind: 0).ransack(params[:q])
    @posts = @q.result(distinct: true)

    direction_notification
  end

  def all_series
    @ejs = JuniorEnterprise.all
    @categories = Category.all

    @q = TvSerie.all.ransack(params[:q])
    @series = @q.result(distinct: true)

    direction_notification
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
		@serie_categories = TvSerieCategory.all
		@categories = Category.all.select(:id, :name)
		@videos = if user_is_admin?
								Post.all.where(owner_id: nil, kind: 1)
							else
								Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 1)
							end

		direction_notification
	end

	def my_trails
		@categories = Category.all.select(:id, :name)
		@serie_categories = TvSerieCategory.all
		series_and_posts
		direction_notification
	end

	def new_serie
		tv_serie = TvSerie.new(name: params[:serie_name], description: params[:serie_description])

		tv_serie.banner_image.attach(params[:banner_image])	if params[:banner_image].present?
		tv_serie.poster_image.attach(params[:poster_image]) if params[:poster_image].present?

		categories = params[:categories].split(',')

		tv_serie.owner_id = if admin_signed_in?
													nil
												else
													current_member.junior_enterprise_id
												end
		if tv_serie.save

			categories.each do |category|
				TvSerieCategory.create(tv_serie_id: tv_serie.id, category_id: category.to_i)
			end

			render json: [msg: "Nova trilha #{params[:serie_name]} foi criada com sucesso!",
										tv_series: user_tv_series]

			flash[:notice] = "Nova trilha  #{params[:serie_name]} foi criada com sucesso"
		else
			flash[:alert] = 'Ocorreu um erro ao salvar nova trilha'
			render json: [msg: 'Erro: Deu ruim']
		end
	end

	def new_season
		if TvSerie.find(params[:id]).nil?
			render json: [msg: 'a trilha atual não foi encontrada']
		else
			@tv_serie = params[:id]
			@last_season = Season.where(tv_serie_id: @tv_serie).maximum('order')
			@new_season = Season.create(tv_serie_id: @tv_serie, order: @last_season + 1)
			render json: [msg: 'Nova temporada adicionada com sucesso', new_season_id: @new_season.id, new_season_order: @new_season.order]
		end
	end

	def delete_season
		season = Season.find(params[:season_id])
		if season.nil?
			render json: [msg: 'temporada não encontrada']
		elsif season.destroy
			render json: [msg: 'Temporada deletada com sucesso']
		end
	end

	def update_season(season_and_posts_hash)
		season_and_posts_hash.each do |season, posts_ids|
			SeasonPost.where(season_id: season.to_i).destroy_all

			posts_for_save = posts_ids.split(',')
			(0..posts_for_save.length).each do |i|
				SeasonPost.create(season_id: season.to_i, post_id: posts_for_save[i].to_i, order: i + 1)
			end
		end
	end

	def update_serie
		# params de entrada: name, description, tv_serie_id
		tv_serie = TvSerie.find_by(id: params[:tv_serie_id])
		if tv_serie.nil?
			# id invalida ou tipo invalido
			render json: [msg: 'Erro: Nenhum resultado encontrado']
		elsif !tv_serie.nil?
			if !verify_onwership(tv_serie)
				# post de outro dono
				render json: [msg: 'Erro: Erro ao encontrar o post']
			else
				tv_serie.name = params[:name] unless params[:name].nil?
				tv_serie.description = params[:description] unless params[:description].nil?

				if params[:banner_image].present?
					tv_serie.banner_image.purge
					tv_serie.banner_image.attach(params[:banner_image])
				end

				if params[:poster_image].present?
					tv_serie.poster_image.purge
					tv_serie.poster_image.attach(params[:poster_image])
				end

				TvSerieCategory.where(tv_serie_id: tv_serie.id).destroy_all

				categories = params[:categories].split(',')

				categories.each do |category|
					TvSerieCategory.create(
						tv_serie_id: tv_serie.id,
						category_id: category.to_i
					)
				end

				if tv_serie.save
					# sucesso
					season_and_posts_hash = JSON.parse(params[:seasons_and_posts])
					update_season(season_and_posts_hash)
					flash[:notice] = 'Sucesso: Post foi atualizado'
					render json: [msg: 'Sucesso: Post foi atualizado', tv_serie: tv_serie]
				else
					# falha
					flash[:alert] = 'Erro: Falha ao atualizad o post'
					render json: [msg: 'Erro: Falha ao atualizad o post']
				end
			end
		end
	end

	def delete_tv_serie
		tv_serie = TvSerie.find(params[:id])
		if tv_serie.nil?
			render json: [msg: 'Erro: Trilha não encontrada']
		else
			if verify_onwership(tv_serie) || admin_signed_in?
				tv_serie.destroy
				render json: [msg: 'Trilha deletada com sucesso']
			else
				render json: [msg: 'Erro: Você não pode excluir esse post']
			end
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
											0
										else
											current_member.junior_enterprise_id
										end

		if post.save
			categories.each do |category|
				PostCategory.create(post_id: post.id, category_id: category.to_i)
			end

			flash[:notice] = 'Vídeo criado com sucesso'
			render json: [msg: 'Sucesso: Vídeo criado']
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
			@season = Season.find(params[:season_id].to_i)
			@posts = []
			@posts = SeasonPost.where(season_id: params[:season_id].to_i)
			if (admin_signed_in? && @season.tv_serie.owner_id.nil?) ||
				 (member_signed_in? && @season.tv_serie.owner_id == current_member.junior_enterprise_id)
				if @posts.nil?
					render json: [msg: 'Você ainda não possui Vídeos nessa Temporada', post: @posts]
				else # nenhuma serie

					render json: [posts: @posts]
				end
			else
				render json: [msg: 'Temporada inválida para você']
			end
		else
			render json: [msg: 'Temporada inválida']
		end
	end

	def posts_from_season
		if params[:season_id].present?
			@season = Season.find(params[:season_id].to_i)
			@season_posts = []
			@posts =[]
			@poster_image = []
			@posts_rating = []
			@season_posts = SeasonPost.where(season_id: params[:season_id])

			@season_posts.each do |season_post|
				@posts << season_post.post
			end

			@posts.each do |post|
				@poster_image << url_for(post.poster_image).to_s
				@posts_rating << post.rating
			end

			# byebug

			if (admin_signed_in? && @season.tv_serie.owner_id.nil?) ||
				(member_signed_in? && @season.tv_serie.owner_id == current_member.junior_enterprise_id)
				if @posts.nil?
					render json: [msg: 'Você ainda não possui Vídeos nessa Temporada', post: @posts]
				else # nenhuma serie

					render json: [posts: @posts, poster_image: @poster_image, rating: @posts_rating]
				end
			else
				render json: [msg: 'Temporada inválida para você']
			end
		else
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

	def serie
		@serie = TvSerie.find(params[:id])
		@videos = Post.all.where(kind: 1)
		@posts = Post.all.where(kind: 0)
		@series = TvSerie.all

		@seasons = Season.all.where(tv_serie_id: @serie.id)
		@seasons = @seasons.sort_by{|season| season.order}

		direction_notification
	end

	def serie_information
		@serie = TvSerie.find(params[:id])

		tv_serie_categories = TvSerieCategory.where(tv_serie_id: @serie.id)

		@categories = []

		tv_serie_categories.each do |tv_serie_category|
			@categories << tv_serie_category.category
		end
		@seasons = Season.where(tv_serie_id: params[:id])
		@first_season = @seasons.each do |season|
			season if season.order == 1
		end
		@posts_from_first_season = SeasonPost.where(season_id: @first_season[0].id)
		render json: [tv_serie_id: @serie.id,
									poster_image: @serie.poster_image,
									banner_image: @serie.banner_image,
									tv_serie_name: @serie.name,
									tv_serie_description: @serie.description,
									tv_serie_categories: @categories,
									tv_serie_seasons: @serie.seasons,
									first_season_posts: @posts_from_first_season]
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

	# def update_video
	#   # params de entrada: name, description, link, video_id
	#   video = Post.find_by(id: params[:video_id])
	#   if !video.video? || video.nil?
	#     # id invalida ou tipo invalido
	#     render json: [msg: 'Erro: Nenhum resultado encontrado']
	#   elsif video.video? || !video.nil?
	#     if !((admin_signed_in? && video.owner_id.nil?) ||
	#         (member_signed_in? && (video.owner_id == current_member.id)))
	#       # video de outro dono
	#       render json: [msg: 'Erro: Erro ao encontrar o vídeo']
	#     else
	#       video.name = params[:name] unless params[:name].nil?
	#       video.description = params[:description] unless params[:description].nil?
	#       video.link = params[:link] unless params[:link].nil?
	#       if video.save
	#         # sucesso
	#         flash[:notice] = 'Sucesso: Vídeo foi atualizado'
	#         render json: [msg: 'Sucesso: Vídeo foi atualizado', video: video]
	#       else
	#         # falha
	#         flash[:alert] = 'Erro: Falha ao atualizad o vídeo'
	#         render json: [msg: 'Erro: Falha ao atualizad o vídeo']
	#       end
	#     end
	#   end
	# end

	def view_counter_update
		post = Post.find(params[:id])
		post.views += 1
		post.save
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

	def series_and_posts(kind = nil)
		if member_signed_in?
			@series = TvSerie.all.where(owner_id: current_logged_user.junior_enterprise_id)
			if kind.nil?
				@all_posts = Post.all.where(owner_id: current_logged_user.junior_enterprise_id)
			elsif kind == 0
				@posts = Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 0)
			elsif kind == 1
				@videos = Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 1)
			end
		else
			@series = TvSerie.all.where(owner_id: nil)
			if kind.nil?
				@all_posts = Post.all.where(owner_id: nil)
			elsif kind == 0
				@posts = Post.all.where(owner_id: nil, kind: 0)
			elsif kind == 1
				@videos = Post.all.where(owner_id: nil, kind: 1)
			end
		end
	end
end
