class TvSeriesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :check_if_user_is_director_or_is_admin, only: :my_trails
  include ApplicationHelper

  def serie
    @serie = TvSerie.find(params[:id])
    @videos = Post.all.where(kind: 1)
    @posts = Post.all.where(kind: 0)
    @series = TvSerie.all

    @seasons = Season.all.where(tv_serie_id: @serie.id)
    @seasons = @seasons.sort_by(&:order)

    direction_notification
  end

  def my_trails
    @categories = Category.all.select(:id, :name)
    @serie_categories = TvSerieCategory.all
    series_and_posts
    direction_notification
  end

  def all_series
    @ejs = JuniorEnterprise.all
    @categories = Category.all

    @q = TvSerie.all.ransack(params[:q])
    @series = @q.result(distinct: true)

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
                  first_season_posts: @posts_from_first_season], status: :ok
  end

  def new_serie
    tv_serie = TvSerie.new(name: params[:serie_name], description: params[:serie_description])

    tv_serie.banner_image.attach(params[:banner_image])	if params[:banner_image].present?
    tv_serie.poster_image.attach(params[:poster_image]) if params[:poster_image].present?

    categories = params[:categories].split(',')

    tv_serie.owner_id = if admin_signed_in?
                          0
                        else
                          current_member.junior_enterprise_id
                        end
    if tv_serie.save

      categories.each do |category|
        TvSerieCategory.create(tv_serie_id: tv_serie.id, category_id: category.to_i)
      end

      render json: [msg: "Nova trilha #{params[:serie_name]} foi criada com sucesso!",
                    tv_series: user_tv_series], status: :ok

    else
      render json: [msg: 'Erro: falha ao criar nova trilha'], status: :unprocessable_entity
    end
  end

  def update_serie
    # params de entrada: name, description, tv_serie_id
    tv_serie = TvSerie.find_by(id: params[:tv_serie_id])
    if tv_serie.nil?
      # id invalida ou tipo invalido
      render json: [msg: 'Erro: Nenhum resultado encontrado'], status: :not_found
    elsif !tv_serie.nil?
      if !verify_onwership(tv_serie)
        # post de outro dono
        render json: [msg: 'Erro: Erro ao encontrar o post'], status: :unauthorized
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
          SeasonsController.update_season(season_and_posts_hash)
          render json: [msg: 'Sucesso: Post foi atualizado', tv_serie: tv_serie], status: :ok
        else
          # falha
          render json: [msg: 'Erro: Falha ao atualizad o post'], status: :unprocessable_entity
        end
      end
    end
  end

  def delete_tv_serie
    tv_serie = TvSerie.find(params[:id])
    if tv_serie.nil?
      render json: [msg: 'Erro: Trilha não encontrada'], status: :not_found
    elsif verify_onwership(tv_serie) || admin_signed_in?
      tv_serie.destroy
      render json: [msg: 'Trilha deletada com sucesso'], status: :ok
    else
      render json: [msg: 'Erro: Você não pode excluir esse post'], status: :unauthorized
    end
  end

  def serie_seasons
    if admin_signed_in? || (member_signed_in? && current_member.validated?)
      seasons = TvSerie.find(params[:serie]).seasons.select(:id, :name)
      render json: [seasons: seasons], status: :ok
    else
      render json: [msg: 'Erro: Série inválida'], status: :unauthorized
    end
  end

  def my_seasons_by_serie
    if params[:serie_id].present?
      serie = TvSerie.where(id: params[:serie_id])
      if serie.count == 1 &&
         (admin_signed_in? && serie.first.owner_id == 0) ||
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
          render json: [msg: 'Você ainda não possui Temporadas nessa Série'], status: :no_content
        else # nenhuma serie
          render json: [series: hash_seasons], status: :ok
        end
      else
        render json: [msg: 'Série inválida para você'], status: :unauthorized
      end
    else
      render json: [msg: 'Série inválida'], status: :not_found
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
									WHERE "series"."owner_id" = '"#{0}"'
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
      render json: series, status: :ok
    else
      render json: [msg: 'Erro: Falha ao recuperar postagens'], status: :not_found
    end
  end

  def series_and_posts(kind = nil)
    if member_signed_in?
      @series = TvSerie.all.where(owner_id: current_logged_user.junior_enterprise_id)
      if kind.nil?
        @all_posts = Post.all.where(owner_id: current_logged_user.junior_enterprise_id)
      elsif kind.zero?
        @posts = Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 0)
      elsif kind == 1
        @videos = Post.all.where(owner_id: current_logged_user.junior_enterprise_id, kind: 1)
      end
    else
      @series = TvSerie.all.where(owner_id: 0)
      if kind.nil?
        @all_posts = Post.all.where(owner_id: 0)
      elsif kind.zero?
        @posts = Post.all.where(owner_id: 0, kind: 0)
      elsif kind == 1
        @videos = Post.all.where(owner_id: 0, kind: 1)
      end
    end
  end
end
