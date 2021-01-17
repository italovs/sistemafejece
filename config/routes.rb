# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :admins
  devise_for :members
  root 'administrative#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
