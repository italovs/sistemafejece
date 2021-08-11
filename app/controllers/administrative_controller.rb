# frozen_string_literal: true

class AdministrativeController < ApplicationController
  skip_before_action :verify_authenticity_token

  layout 'administrative'
  include ApplicationHelper
  def index
    @label_days = []
    @activity = Activity.all.pluck(:quantity)
    Activity.all.each do |day|
      labelday = "#{day.created_at.day}/#{day.created_at.month}"
      @label_days << labelday unless @label_days.include? labelday
    end
    @activity_data = {}
    @nps_promotor = Vote.where('value > 8')
    @nps_detrator = Vote.where('value < 7')
    @nps_neutro = Vote.where(value: [7, 8])

    @posts_asc = []
    Post.all.each do |post|
      @posts_asc << {"name": post.name, "rating": post.rating} if post.rating != -1
    end

    @posts_asc = @posts_asc.sort_by { |post| post[:rating] }
    @posts_desc = @posts_asc.reverse
  end

  def members_validation
    return_members
  end

  def profile_admin
    @profile = current_admin
  end

  def change_member_validation
    membro = Member.find(params[:id])
    membro.validated = params[:status]
    ActiveRecord::Base.transaction do
      membro.save
      @directors = Member.where(validated: true)
      return_members
      @directors = @directors.map { |m| [m.id, m.name, m.junior_enterprise.name] }
      @not_yet_directors = @not_yet_directors.map { |m| [m.id, m.name, m.junior_enterprise.name] }
      render json: [msg: 'Sucesso', directors: @directors, members: @not_yet_directors], status: :ok
    end
  rescue ActiveRecord::RecordInvalid
    render json: [msg: 'Erro'], status: :unprocessable_entity
  end

  def new_admins
    @admins = Admin.all
  end

  def admin_info
    admin = Admin.find(params[:id])
    if admin.nil?
      render json: [msg: 'admin não encontrado'], status: :not_found
    else
      render json: [admin_name: admin.name, admin_email: @admin.email], status: :ok
    end
  end

  def create_admin
    admin = Admin.new(name: params[:name], email: params[:email], password: params[:password])
    if admin.save
      render json: [msg: 'Administrador criado com sucesso'], status: :ok
    else
      render json: [msg: "Erro: #{admin.errors}"], status: :unprocessable_entity
    end
  end

  def update_admin
    admin = Admin.find(params[:id])
    admin.email = params[:email] if params[:email].present?
    admin.name = params[:name] if params[:name].present?
    admin.password = params[:password] if params[:password].present?
    if admin.save
      render json: [msg: 'Administrador Atualizado com sucesso'], status: :ok
    else
      render json: [msg: "Falha ao salvar atualização #{admin.errors}"], status: :unprocessable_entity
    end
  end

  def remove_admin
    admin = Admin.find(params[:id]) if params[:id].present?
    if Admin.all.count == 1
      render json: [msg: 'impossivel deletar o último administrador'], status: :not_acceptable
    else
      admin.destroy
      render json: [msg: 'Pirata removido com sucesso!'], status: :ok
    end
  end

  # EJS
  def junior_enterprises
    @junior_enterprises = JuniorEnterprise.all.order(name: :asc)
  end

  def new_junior_enterprise
    @ej = JuniorEnterprise.new(name: params[:name], description: params[:description])
    if @ej.save
      render json: [msg: 'Empresa Junior criada com sucesso', ejs: JuniorEnterprise.all.select(:id, :name, :description)], status: :ok
    else
      render json: [msg: "Erro: #{@admin.errors}"], status: :unprocessable_entity
    end
  end

  def junior_enterprise_info
    ej = JuniorEnterprise.find(params[:id])
    if ej.nil?
      render json: [msg: 'Empresa junior não encontrada'], status: :not_found
    else
      render json: [ej_name: ej.name, ej_description: ej.description], status: :ok
    end
  end

  def update_junior_enterprise
    ej = JuniorEnterprise.find(params[:id])
    ej.name = params[:name]
    ej.description = params[:description]

    if ej.save
      render json: [msg: 'Empresa junior atualizada com sucesso'], status: :ok
    else
      render json: [msg: "Falha ao atualizar empresa junior #{ej.errors}"], status: :unprocessable_entity
    end
  end

  def remove_junior_enterprise
    ej = JuniorEnterprise.find(params[:id]) if params[:id].present?

    if ej.members.count.zero?
      ej.destroy
      render json: [msg: 'Empresa junior deletada com sucesso', ejs: JuniorEnterprise.all.select(:id, :name, :description)], status: :ok
    else
      render json: [msg: ej.members.count == 1 ? 'Erro: Há 1 membro associado a esta EJ' : "Erro: Há #{ej.members.count} membros associados a esta EJ"],
             status: :not_acceptable
    end
  end
  # FIM EJS

  def categories
    @categories = Category.all.order(name: :asc)
  end

  def new_category
    category = Category.create(name: params[:name], description: params[:description])
    ActiveRecord::Base.transaction do
      category.save
      render json: [msg: 'Categoria criada com sucesso', ejs: Category.all.select(:name, :description)], status: :ok
    end
  rescue ActiveRecord::RecordInvalid
    render json: [msg: "Erro: #{admin.errors}"], status: :unprocessable_entity
  end

  def update_category
    category = Category.find(params[:id])
    category.name = params[:name]
    category.description = params[:description]

    if category.save
      render json: [msg: 'Categoria atualizada com sucesso'], status: :ok
    else
      render json: [msg: 'Falha ao atualizar categoria'], status: :unprocessable_entity
    end
  end

  def category_info
    category = Category.find(params[:id])
    if category.nil?
      render json: [msg: 'Não foi possivel localizar essa categoria'], status: :not_found
    else
      render json: [category_name: category.name, category_decription: category.description], status: :ok
    end
  end

  def remove_category
    category = Category.find(params[:id])
    if category.nil?
      render json: [msg: 'Categoria não encontrada'], status: :not_found
    elsif category.destroy
      render json: [msg: 'Categoria deletada com sucesso'], status: :ok
    else
      render json: [msg: 'Falha ao deletar categoria'], status: :unprocessable_entity
    end
  end

  private

  def return_members
    @directors = Member.where(validated: true)
    @not_yet_directors = Member.where(validated: nil)
  end
end
