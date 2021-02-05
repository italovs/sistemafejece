# frozen_string_literal: true

Rails.application.routes.draw do
	devise_for :admins, controllers: {
		sessions: 'admins/sessions',
		registrations: 'admins/registrations',
	}

	devise_for :members, controllers: {
		sessions: 'members/sessions'
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
				get '/categories', to: 'administrative#categories', as: 'categories'
				post '/categories', to: 'administrative#new_category', as: 'new_category'
			end
			
			get '/profile', to: 'site#profile', as: 'admin_profile'
			post '/change_password', to: 'site#change_password', as: 'change_admin_password'
			post '/change_mail', to: 'site#change_mail', as: 'change_admin_mail'
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
				end

				unauthenticated :member  do
					root 'members/sessions#new', as: 'not_logged_member_root'
				end
			end
		end

	end

	# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
