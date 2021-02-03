class SiteController < ApplicationController
	layout "member"
	include ApplicationHelper
	skip_before_action :verify_authenticity_token

	def index
	end

	def profile
		@ejs = JuniorEnterprise.all.map { |ej| [ ej.name,  ej.id, ]}
		if member_signed_in?
			@profile = current_member
		elsif admin_signed_in?
			@profile = current_admin
		end
		@directories = [ ["Membro", false], ["Diretoria", true], ["Solicitar Dirertoria", ""] ]
	end

	def request_to_become_a_director
		@member = current_member
		ActiveRecord::Base.transaction do
			@member.validated = nil
			@member.save
			render json: [msg: "Valeu, meu consagrado!", member: @member, junior_enterprise: @member.junior_enterprise.name]
		end

		rescue  ActiveRecord::RecordInvalid
			render json: [msg: "Erro: "+	@member.errors ]
	end
end
