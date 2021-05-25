# frozen_string_literal: true

class AdministrativeController < ApplicationController
  skip_before_action :verify_authenticity_token

  layout 'administrative'
  include ApplicationHelper
  def index
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

  def create_admin
    @admin = Admin.new(name: params[:name], email: params[:email], password: params[:password])
    if @admin.save
      render json: [msg: 'Administrador criado com sucesso'], status: :ok
    else
      render json: [msg: "Erro: #{@admin.errors}"], status: :unprocessable_entity
    end
  end

  def remove_admin
    admin = Admin.find(params[:id]) if params[:id].present?
    admin.destroy
    render json: [msg: 'Pirata removido com sucesso!'], status: :ok
  end

  # EJS
  def junior_enterprises
    @junior_enterprises = JuniorEnterprise.all
  end

  def new_junior_enterprise
    @ej = JuniorEnterprise.new(name: params[:name], description: params[:description])
    if @ej.save
      render json: [msg: 'Empresa Junior criada com sucesso', ejs: JuniorEnterprise.all.select(:id, :name, :description)], status: :ok
    else
      render json: [msg: "Erro: #{@admin.errors}"], status: :unprocessable_entity
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
    @categories = Category.all
  end

  def new_category
    @category = Category.create(name: params[:name], description: params[:description])
    ActiveRecord::Base.transaction do
      @category.save
      render json: [msg: 'Categoria criada com sucesso', ejs: Category.all.select(:name, :description)], status: :ok
    end
  rescue ActiveRecord::RecordInvalid
    render json: [msg: "Erro: #{@admin.errors}"], status: :unprocessable_entity
  end



  private

  def return_members
    @directors = Member.where(validated: true)
    @not_yet_directors = Member.where(validated: nil)
  end
end
