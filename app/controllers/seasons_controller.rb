class SeasonsController < ApplicationController
  skip_before_action :verify_authenticity_token
  include ApplicationHelper

  def new_season
    if TvSerie.find(params[:id]).nil?
      render json: [msg: 'a trilha atual não foi encontrada'], status: :not_found
    else
      @tv_serie = params[:id]
      @last_season = Season.where(tv_serie_id: @tv_serie).maximum('order')
      @new_season = Season.create(tv_serie_id: @tv_serie, order: @last_season + 1)
      render json: [msg: 'Nova temporada adicionada com sucesso',
                    new_season_id: @new_season.id, new_season_order: @new_season.order], status: :ok
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

  def posts_from_season
    if params[:season_id].present?
      @season = Season.find(params[:season_id].to_i)
      @season_posts = []
      @posts = []
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

      if (admin_signed_in? && @season.tv_serie.owner_id.nil?) ||
         (member_signed_in? && @season.tv_serie.owner_id == current_member.junior_enterprise_id)
        if @posts.nil?
          render json: [msg: 'Você ainda não possui Vídeos nessa Temporada', post: @posts],
                 status: :no_content
        else # nenhuma serie

          render json: [posts: @posts, poster_image: @poster_image, rating: @posts_rating],
                 status: :ok
        end
      else
        render json: [msg: 'Temporada inválida para você'], status: :unauthorized
      end
    else
      render json: [msg: 'Temporada inválida'], status: :not_found
    end
  end

  def my_posts_by_season
    if params[:season_id].present?
      @season = Season.find(params[:season_id].to_i)
      @posts = []
      @posts = SeasonPost.where(season_id: params[:season_id].to_i)
      if (admin_signed_in? && @season.tv_serie.owner_id.nil?) ||
         (member_signed_in? && @season.tv_serie.owner_id == current_member.junior_enterprise_id)
        if @posts.nil?
          render json: [msg: 'Você ainda não possui Vídeos nessa Temporada', post: @posts],
                 status: :no_content
        else # nenhuma serie

          render json: [posts: @posts], status: :ok
        end
      else
        render json: [msg: 'Temporada inválida para você'], status: :unauthorized
      end
    else
      render json: [msg: 'Temporada inválida'], status: :not_found
    end
  end

  def delete_season
    season = Season.find(params[:season_id])
    if season.nil?
      render json: [msg: 'temporada não encontrada'], status: :not_found
    elsif season.destroy
      render json: [msg: 'Temporada deletada com sucesso'], status: :ok
    end
  end
end
