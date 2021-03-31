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

	def current_logged_user
		if member_signed_in?
			current_member
		elsif admin_signed_in?
			current_admin
		end
	end

	def logged_root
		if member_signed_in?
			member_root_path
		elsif admin_signed_in?
			admin_root_path
		end
	end

	def profile_path
		if member_signed_in?
			member_profile_path
		elsif admin_signed_in?
			profile_admin_path
		end
	end

	def current_user_post_path(element)
		if member_signed_in?
			member_post_path(element)
		elsif admin_signed_in?
			admin_post_path(element)
		end
	end

	def current_user_serie_path(element)
		if member_signed_in?
			member_serie_path(element)
		elsif admin_signed_in?
			admin_serie_path(element)
		end
	end

	def collect_categories_ids(aux)
		vector = []
		
		aux.each do |aux|
			vector.push(aux[:category_id])
		end

		string = " ,"
		
		vector.each do |element|
			string += @categories.all.find{|c| c.id == element}.name
			string += ", "
		end
		string = string[2...-2]
	end

	def best_evaluated(vector_2)
		vector = []

		@posts.each do |post|
			vector << ({post: post, rating: post.rating})
		end

		vector = vector.sort_by{|hash| hash[:rating]}
		vector = vector.reverse()
		
		vector.each do |element|
			vector_2 << (element[:post])
		end

		vector_2 = vector_2.reverse()
	end
end
