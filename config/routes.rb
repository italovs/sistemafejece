# frozen_string_literal: true

Rails.application.routes.draw do
	get 'site/index'
	get 'site/perfil'
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
				resources :junior_enterprises
				get '/directors', to: 'administrative#members_validation', as: 'members_validation'
				post '/directors/change_validation', to: 'administrative#change_member_validation', as: 'change_member_validation'
				get '/new_pirates', to: 'administrative#new_admins', as: 'new_admins'
				post '/new_pirates', to: 'administrative#create_admin', as: 'create_admin'
				get '/junior_enterprises', to: 'administrative#junior_enterprises', as: 'junior_enterprises'
				post '/junior_enterprises', to: 'administrative#new_junior_enterprise', as: 'new_junior_enterprise'
			end

			root 'administrative#index', as: 'admin_root'
		end

		unauthenticated :admin do
			devise_scope :member do
				authenticated :member do
					root 'administrative#index', as: 'member_root'
				end

				unauthenticated :member  do
					root 'members/sessions#new', as: 'not_logged_member_root'
				end
			end
		end

	end

	# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
