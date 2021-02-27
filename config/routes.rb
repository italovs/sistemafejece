# frozen_string_literal: true

Rails.application.routes.draw do
	devise_for :admins, controllers: {
		sessions: 'admins/sessions',
		registrations: 'admins/registrations',
	}

	devise_for :members, controllers: {
		sessions: 'members/sessions',
		registrations: 'members/registrations'
	}

	devise_scope :admin do
		authenticated :admin do
			scope '/pirates' do
				get '/', to: 'administrative#index', as: 'administrative_index'
				get '/directors', to: 'administrative#members_validation', as: 'members_validation'
				post '/directors', to: 'administrative#change_member_validation', as: 'change_member_validation'
				get '/new_pirates', to: 'administrative#new_admins', as: 'new_admins'
				post '/new_pirates', to: 'administrative#create_admin', as: 'create_admin'
				get '/junior_enterprises', to: 'administrative#junior_enterprises', as: 'junior_enterprises'
				post '/junior_enterprises', to: 'administrative#new_junior_enterprise', as: 'new_junior_enterprise'
				post '/junior_enterprises/remove', to: 'administrative#remove_junior_enterprise', as: 'remove_junior_enterprise'
				get '/categories', to: 'administrative#categories', as: 'categories'
				post '/categories', to: 'administrative#new_category', as: 'new_category'
			end
			
			get '/profile', to: 'administrative#profile_admin', as: 'profile_admin'
			post '/change_password', to: 'site#change_password', as: 'change_admin_password'
			post '/change_mail', to: 'site#change_mail', as: 'change_admin_mail'
			post '/change_information', to: 'site#change_information', as: 'change_admin_information'
			get '/my_channel', to: 'site#my_channel', as: 'admin_my_channel'
			post '/new_serie', to: 'site#new_serie', as: 'admin_new_serie'
			post '/serie_seasons', to: 'site#serie_seasons', as: 'admin_serie_seasons'
			post '/new_video', to: 'site#new_video', as: 'admin_new_video'
			post '/my_posts', to: 'site#my_posts', as: 'admin_my_posts'
			post '/new_post', to: 'site#new_post', as: 'admin_new_post'

			get '/my_library', to: 'site#my_library', as: 'admin_my_library'
			root 'site#index', as: 'admin_root'
		end

		unauthenticated :admin do
			devise_scope :member do
				authenticated :member do
					root 'site#index', as: 'member_root'
					get '/profile', to: 'site#profile', as: 'member_profile'
					post '/request_to_become_a_director', to: 'site#request_to_become_a_director', as: 'request_to_become_a_director'
					post '/change_password', to: 'site#change_password', as: 'change_member_password'
					post '/change_mail', to: 'site#change_mail', as: 'change_member_mail'
					post '/change_information', to: 'site#change_information', as: 'change_member_information'
					
					#validated
					get '/my_channel', to: 'site#my_channel', as: 'validated_my_channel'
					post '/new_serie', to: 'site#new_serie', as: 'validated_new_serie'
					post '/serie_seasons', to: 'site#serie_seasons', as: 'validated_serie_seasons'
					post '/new_video', to: 'site#new_video', as: 'validated_new_video'

					get '/my_library', to: 'site#my_library', as: 'validated_my_library'
					post '/my_posts', to: 'site#my_posts', as: 'validated_my_posts'
					post '/new_post', to: 'site#new_post', as: 'validated_new_post'
				end

				unauthenticated :member  do
					root 'members/sessions#new', as: 'not_logged_member_root'
				end
			end
		end

	end

	# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
