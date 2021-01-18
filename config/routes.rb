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
