# frozen_string_literal: true

class AdministrativeController < ApplicationController
	layout 'administrative'
	include ApplicationHelper
	def index
	end

	def members_validation
		return_members
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
			render json: [msg: "Sucesso", directors: @directors, members: @not_yet_directors]
		end

		rescue ActiveRecord::RecordInvalid
			render json: [msg: "Erro"]
	end

	def new_admins
	end

	def create_admin
		puts params[:my_form_data]
		@admin = Admin.create(name: params[:my_form_data][:name], email: params[:my_form_data][:email], password: params[:my_form_data][:password] )
		ActiveRecord::Base.transaction do
			@admin.save
			render json: [msg: "Valeu, meu consagrado!"]
		end

		rescue  ActiveRecord::RecordInvalid
			render json: [msg: "Erro: "+	@admin.errors ]
	end

	private
	def return_members
		@directors = Member.where(validated: true)
		@not_yet_directors = Member.where(validated: nil)
	end
end
