class PostsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :check_if_user_is_director_or_is_admin, only: [:my_channel, :my_library]
  include ApplicationHelper

  def index
    @posts = Post.all
  end

  def my_channel
    user_tv_series
    @serie_categories = TvSerieCategory.all
    @categories = Category.all.select(:id, :name)
    @videos = if user_is_admin?
                Post.all.where(owner_id: 0, kind: 1)
              else
                Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 1)
              end

    direction_notification
  end

  def my_library
    @videos = Post.all.where(kind: 1)
    @categories = Category.all.select(:id, :name)
    @post_categories = PostCategory.all
    @posts = if user_is_admin?
                Post.all.where(owner_id: 0, kind: 0)
             else
              Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 0)
             end

    direction_notification
  end

  def post
    @videos = Post.all.where(kind: 1)
    @post = Post.find(params[:id])
    @posts = Post.all
    @ej = JuniorEnterprise.all.find{|ej| ej.id == @post.owner_id}
    @votes = Vote.all
    @post_categories = PostCategory.where(post_id: @post.id)
    @categories = Category.all

    direction_notification
  end

  def all_posts
    @ejs = JuniorEnterprise.all
    @categories = Category.all

    @q = Post.all.where(kind: 0).ransack(params[:q])
    @posts = @q.result(distinct: true)

    direction_notification
  end

  def all_videos
    # @custom_ejs = []
    # @custom_ejs << ({id: nil, name: "Todas as EJs"})
    # JuniorEnterprise.all.each do |ej|
    #   @custom_ejs << ({id: ej.id, name: ej.name})
    # end
    # @custom_ejs << ({id: nil, name: "FEJECE"})
    @ejs = JuniorEnterprise.all
    @categories = Category.all

    @q = Post.where(kind: 1).ransack(params[:q])
    @videos = @q.result(distinct: true)

    direction_notification
  end

  def post_information
    @post = Post.find(params[:id])

    @post_categories = PostCategory.where(post_id: @post.id)

    @categories = []

    @post_categories.each do |post_category|
      @categories << post_category.category
    end

    render json: [post_id: @post.id,
                  post_image: url_for(@post.poster_image),
                  banner_image: @post.banner_image,
                  post_name: @post.name,
                  post_description: @post.description,
                  post_link: @post.link,
                  post_categories: @categories], status: :ok
  end

  def new_post
    file_post = Post.new(
      name: params[:name],
      description: params[:description],
      link: params[:link],
      kind: Post.kinds[:post]
    )
    file_post.banner_image.attach(params[:banner_image]) if params[:banner_image].present?
    file_post.poster_image.attach(params[:poster_image]) if params[:poster_image].present?

    categories = params[:categories].split(',')
    file_post.owner_id =	if admin_signed_in?
                           0
                         else
                           current_member.junior_enterprise_id
                         end
    if file_post.save
      categories.each do |category|
        PostCategory.create(post_id: file_post.id, category_id: category.to_i)
      end
      render json: [msg: 'Sucesso: post criado'], status: :created
    else
      render json: [msg: 'Erro: Falha ao criar post'], status: :unprocessable_entity
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

      render json: [msg: 'Sucesso: Vídeo criado'], status: :created
    else
      render json: [msg: 'Erro: Falha ao criar vídeo'], status: :unprocessable_entity
    end
  end

  def update_post
    # params de entrada: name, description, link, post_id
    post = Post.find_by(id: params[:post_id])
    if post.nil?
      # id invalida ou tipo invalido
      render json: [msg: 'Erro: Nenhum resultado encontrado']
    elsif !post.nil?
      if !verify_onwership(post)
        # post de outro dono
        render json: [msg: 'Erro: Erro ao encontrar o post']
      else
        post.name = params[:name] unless params[:name].nil?
        post.description = params[:description] unless params[:description].nil?
        post.link = params[:link] unless params[:link].nil?

        if params[:banner_image].present?
          post.banner_image.purge
          post.banner_image.attach(params[:banner_image])
        end

        if params[:poster_image].present?
          post.poster_image.purge
          post.poster_image.attach(params[:poster_image])
        end

        post_categories = PostCategory.where(post_id: post.id)
        post_categories.destroy_all

        categories = params[:categories].split(',')

        categories.each do |category|
          PostCategory.create(
            post_id: post.id,
            category_id: category.to_i
          )
        end

        if post.save
          # sucesso
          render json: [msg: 'Sucesso: Post foi atualizado', post: post], status: :ok
        else
          # falha
          render json: [msg: 'Erro: Falha ao atualizar o post'], status: :unprocessable_entity
        end
      end
    end
  end

  def video
    @post = SeasonPost.find(params[:id]).post
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
      render json: posts, status: :ok
    else
      render json: [msg: 'Erro: Falha ao recuperar postagens'], status: :not_found
    end
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
      render json: [msg: 'Você ainda não possui séries'], status: :no_content
    else # nenhuma serie
      render json: [series: videos], status: :ok
    end
  end

  def delete_post
    post = Post.find_by(id: params[:id])
    if post.nil?
      render json: [msg: 'Erro: Post ou Vídeo inválido'], status: :bad_request
    else
      if verify_onwership(post) || admin_signed_in?
        # verificar aqui se o post está em alguma série
        post.destroy
        render json: [msg: 'Publicação deletada com sucesso'], status: :ok
      else
        render json: [msg: 'Erro: Você não pode excluir esse post'], status: :unauthorized
      end
    end
  end
end
