class SiteController < ApplicationController
  layout 'member', except: [:profile, :all_content]
  include ApplicationHelper
  before_action :search
  skip_before_action :verify_authenticity_token

  def index
    direction_notification
    @categories = Category.all.select(:id, :name)
    @post_categories = PostCategory.all
    @videos = []
    @posts = []
    @series = []
    series_count = TvSerie.count
    @last_videos = Post.where(kind: 1).select(:id,
      :name,
      :created_at,
      :link,
      :description,
      :kind).last(30)
    @last_posts = Post.where(kind: 0).select(:id,
      :name,
      :created_at,
      :link,
      :description,
      :kind).last(30)
    @posts_and_videos = Post.order(views: :desc).select(:id,
      :name,
      :created_at,
      :link,
      :kind).last(12)
    9.times do
      @sample = @last_posts.sample
      @posts << @sample unless @posts.include? @sample
      @sample = @last_videos.sample
      @videos << @sample unless @videos.include? @sample
      random_offset = rand(series_count)
      @serie = TvSerie.offset(random_offset).first
      @series << @serie unless @series.include? @serie
    end

    q = params[:q]
    @series_search = TvSerie.ransack(junior_enterprise_name_cont: q).result
    @posts_search = Post.ransack(junior_enterprise_name_cont: q).result
  end

  def profile
    @ejs = JuniorEnterprise.all.map { |ej| [ej.name, ej.id] }
    @profile = current_member
    @positions = Member.positions.map { |k, _v| [k.capitalize, k] }
    @directories = [['Membro', false], ['Diretoria', true], ['Solicitar Dirertoria', '']]
  end

  def all_content
    @ejs = JuniorEnterprise.all
    @categories = Category.all

    q0 = params[:q0]
    q1 = params[:q1]
    q2 = params[:q2]
    q3 = params[:q3]
    @posts = Post.ransack(name_cont: q0, owner_id_eq: q1, post_category_category_id_eq: q2,
                          name_or_junior_enterprise_name_or_post_category_category_name_cont: q3).result
    @series = TvSerie.ransack(name_cont: q0, owner_id_eq: q1, tv_serie_category_category_id_eq: q2,
                              name_or_junior_enterprise_name_or_tv_serie_category_category_name_cont: q3).result

    direction_notification
  end

  def all_videos
    # @custom_ejs = []
    # @custom_ejs << ({id: nil, name: "Todas as EJs"})
    # JuniorEnterprise.all.each do |ej|
    #   @custom_ejs << ({id: ej.id, name: ej.name})
    # end
    # @custom_ejs << ({id: nil, name: "FEJECE"})
    # byebug
    @ejs = JuniorEnterprise.all
    @categories = Category.all

    @q = Post.where(kind: 1).ransack(params[:q])
    @videos = @q.result(distinct: true)

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
						somente jpg, png e jpeg são validos'], status: :unsupported_media_type and return
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
        if member_signed_in?
          render json: [msg: 'Sucesso: Deu bom, meu bacano',
                        person: person_information(@person),
                        junior_enterprise: @person.junior_enterprise.name], status: :ok
        else
          render json: [msg: 'Sucesso: Deu bom, meu bacano',
                        person: person_information(@person)], status: :ok
        end
      else
        if member_signed_in?
          render json: [msg: 'Erro: Falha em salvar novo e-mail',
                        person: person_information(@person),
                        junior_enterprise: @person.junior_enterprise.name], status: :unprocessable_entity
        else
          render json: [msg: 'Erro: Falha em salvar novo e-mail',
                        person: person_information(@person)], status: :unprocessable_entity
        end
      end
    else
      if member_signed_in?
        render json: [msg: 'Erro: Senha inválida',
                      person: person_information(@person),
                      junior_enterprise: @person.junior_enterprise.name], status: :unauthorized
      else
        render json: [msg: 'Erro: Senha inválida',
                      person: person_information(@person)], status: :unauthorized
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
                          junior_enterprise: @person.junior_enterprise.name], status: :ok
          else
            render json: [msg: 'Sucesso: Deu bom, meu bacano',
                          person: person_information(@person)], status: :ok
          end
        else
          if member_signed_in?
            render json: [msg: 'Erro: Falha em salvar novo e-mail',
                          person: person_information(@person),
                          junior_enterprise: @person.junior_enterprise.name], status: :unprocessable_entity
          else
            render json: [msg: 'Erro: Falha em salvar novo e-mail',
                          person: person_information(@person)], status: :unprocessable_entity
          end
        end
      else
        if member_signed_in?
          render json: [msg: 'Erro: Campos de novo e-mail não são iguais',
                        person: person_information(@person),
                        junior_enterprise: @person.junior_enterprise.name], status: :unprocessable_entity
        else
          render json: [msg: 'Erro: Campos de novo e-mail não são iguais',
                        person: person_information(@person)], status: :unprocessable_entity
        end
      end
    else
      flash[:alert] = 'Erro: Senha inválida'
      if member_signed_in?
        render json: [msg: 'Erro: Senha inválida',
                      person: person_information(@person),
                      junior_enterprise: @person.junior_enterprise.name], status: :unauthorized
      else
        render json: [msg: 'Erro: Senha inválida', person: person_information(@person)], status: :unauthorized
      end
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
      render json: [msg: 'Você ainda não possui séries nessa categoria'], status: :no_content
    else # nenhuma serie
      render json: [series: hash_series], status: :ok
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
      render json: [msg: 'Você ainda não possui séries'], status: :no_content
    else # nenhuma serie
      render json: [categories: hash_categories], status: :ok
    end
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
      if admin_signed_in?
        render json: [msg: 'Sucesso: Sua nota foi salva',
                      vote_information: vote.post.vote_information(current_admin, true)], status: :ok
      else
        render json: [msg: 'Sucesso: Sua nota foi salva',
                      vote_information: vote.post.vote_information(current_member, false)], status: :ok
      end
    else
      render json: [msg: 'Erro: Falha ao salvar nota'], status: :unprocessable_entity
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
      render json: videos, status: :ok
    else
      render json: [msg: 'Erro: Nenhum resultado encontrado'], status: :not_found
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
      render json: posts, status: :ok
    else
      render json: [msg: 'Erro: Nenhum resultado encontrado'], status: :not_found
    end
  end

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

  def search
    if params[:q]
      search_params = CGI.escapeHTML(params[:q])
      redirect_to("/all_content?q3=#{search_params}")
    end
  end
end
