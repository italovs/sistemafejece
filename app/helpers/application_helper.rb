# frozen_string_literal: true

module ApplicationHelper

	def logout_path
		if member_signed_in?
			destroy_member_session_path
		elsif admin_signed_in?
			destroy_admin_session_path
		end
	end

	#recebe até 2 arrays de strings como parâmetros
	def verifica_controller_ativo( controllers, view = [controller.action_name] )
		if( controllers.include?( controller_name ) && ( view.include?(controller.action_name) ) )
			return 'active'
		else
			return ''
		end
	end

	#serão descartados adiante
	def logged_name
		if member_signed_in?
			current_member.try(:name)
		elsif admin_signed_in?
			current_admin.try(:name)
		end
	end

	def logged_root
		if member_signed_in?
			member_root_path
		elsif admin_signed_in?
			admin_root_path
		end
	end
end
