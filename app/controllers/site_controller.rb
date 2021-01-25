class SiteController < ApplicationController
	def index
	end

	def perfil
		@ejs = JuniorEnterprise.all.map { |ej| [ ej.name,  ej.id, ]}
		if member_signed_in?
			@profile = current_member
		elsif admin_signed_in?
			@profile = current_admin
		end
		@directories = [ ["Membro", false], ["Diretoria", true], ["Solicitar Dirertoria", ""] ]
	end
end
