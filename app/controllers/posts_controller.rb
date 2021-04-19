class PostsController < ApplicationController
  def index
    @posts = Post.all
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
                  post_categories: @categories]
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
    file_post.owner_id = if admin_signed_in?
                           nil
                         else
                           current_member.junior_enterprise_id
                         end
    if file_post.save
      categories.each do |category|
        PostCategory.create(post_id: file_post.id, category_id: category.to_i)
      end
      render json: [msg: 'Sucesso: post criado']
    else
      render json: [msg: 'Erro: Falha ao criar post']
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
          render json: [msg: 'Sucesso: Post foi atualizado', post: post]
        else
          # falha
          render json: [msg: 'Erro: Falha ao atualizad o post']
        end
      end
    end
  end

  def delete_post
    post = Post.find_by(id: params[:id])
    if post.nil?
      render json: [msg: 'Erro: Post ou Vídeo inválido']
    else
      if verify_onwership(post) || admin_signed_in?
        # verificar aqui se o post está em alguma série
        post.destroy
        render json: [msg: 'Publicação deletada com sucesso']
      else
        render json: [msg: 'Erro: Você não pode excluir esse post']
      end
    end
  end
end
