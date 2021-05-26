# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations'
  }

  devise_for :members, controllers: {
    sessions: 'members/sessions',
    registrations: 'members/registrations',
    confirmations: 'members/confirmations'
  }

  devise_scope :admin do
    authenticated :admin do
      scope '/pirates' do
        get '/', to: 'administrative#index', as: 'administrative_index'
        get '/directors', to: 'administrative#members_validation', as: 'members_validation'
        post '/directors', to: 'administrative#change_member_validation', as: 'change_member_validation'
        get '/new_pirates', to: 'administrative#new_admins', as: 'new_admins'
        post '/new_pirates', to: 'administrative#create_admin', as: 'create_admin'
        post '/remove_pirate', to: 'administrative#remove_admin', as: 'remove_admin'
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
      get '/my_channel', to: 'posts#my_channel', as: 'admin_my_channel'
      get '/my_trails', to: 'tv_series#my_trails', as: 'admin_my_trails'
      post '/new_serie', to: 'tv_series#new_serie', as: 'admin_new_serie'
      post '/serie_seasons', to: 'tv_series#serie_seasons', as: 'admin_serie_seasons'
      post '/season', to: 'seasons#my_posts_by_season', as: 'admin_season'
      post '/posts_from_season', to: 'seasons#posts_from_season', as: 'admin_posts_from_season'
      post '/delete_season', to: 'seasons#delete_season', as: 'admin_delete_season'
      post '/new_season', to: 'seasons#new_season', as: 'admin_new_season'
      post '/new_video', to: 'posts#new_video', as: 'admin_new_video'
      get '/video/:id', to: 'posts#video', as: 'admin_video'
      post '/my_series', to: 'tv_series#my_series', as: 'admin_my_series'
      post '/my_categories', to: 'site#my_categories', as: 'admin_my_categories'
      post '/my_series_by_category', to: 'site#my_series_by_category', as: 'admin_my_series_by_category'
      post '/my_seasons_by_serie', to: 'tv_series#my_seasons_by_serie', as: 'admin_my_seasons_by_serie'

      post '/my_videos', to: 'posts#my_videos', as: 'admin_my_videos' # CANDIDATO A SER REMOVIDO

      post '/search_for_video', to: 'site#search_for_video', as: 'admin_search_for_video'
      post '/search_for_post', to: 'site#search_for_post', as: 'admin_search_for_post'

      post '/my_posts', to: 'posts#my_posts', as: 'admin_my_posts'
      post '/new_post', to: 'posts#new_post', as: 'admin_new_post'
      get  '/post/:id', to: 'posts#post', as: 'admin_post'
      post '/post_information', to: 'posts#post_information', as: 'admin_post_information'
      post '/serie_information', to: 'tv_series#serie_information', as: 'admin_serie_information'
      post '/delete_post', to: 'posts#delete_post', as: 'admin_delete_post'
      post '/delete_serie', to: 'tv_series#delete_tv_serie', as: 'admin_delete_serie'
      post '/update_serie', to: 'tv_series#update_serie', as: 'admin_update_serie'
      post '/update_post', to: 'posts#update_post', as: 'admin_update_post'

      get '/my_library', to: 'posts#my_library', as: 'admin_my_library'
      root 'site#index', as: 'admin_root'
      post '/new_vote', to: 'site#new_vote', as: 'admin_new_vote'

      get '/serie/:id', to: 'tv_series#serie', as: 'admin_serie'

      post '/update_views', to: 'site#view_counter_update', as: 'admin_view_counter_update'
      get '/all_content', to: 'site#all_content', as: 'admin_all_content'
      get '/all_videos', to: 'posts#all_videos', as: 'admin_all_videos'
      get '/all_posts', to: 'posts#all_posts', as: 'admin_all_posts'
      get '/all_series', to: 'tv_series#all_series', as: 'admin_all_series'
    end

    unauthenticated :admin do
      devise_scope :member do
        authenticated :member do
          root 'site#index', as: 'member_root'
          get  '/profile', to: 'site#profile', as: 'member_profile'
          post '/request_to_become_a_director', to: 'site#request_to_become_a_director', as: 'request_to_become_a_director'
          post '/change_password', to: 'site#change_password', as: 'change_member_password'
          post '/change_mail', to: 'site#change_mail', as: 'change_member_mail'
          post '/change_information', to: 'site#change_information', as: 'change_member_information'
          get  '/video/:id', to: 'posts#video', as: 'member_video'
          post '/search_for_video', to: 'site#search_for_video', as: 'member_search_for_video'
          post '/search_for_post', to: 'site#search_for_post', as: 'member_search_for_post'
          # validated
          get  '/my_channel', to: 'posts#my_channel', as: 'validated_my_channel'
          get  '/my_trails', to: 'tv_series#my_trails', as: 'validated_my_trails'
          post '/new_serie', to: 'tv_series#new_serie', as: 'validated_new_serie'
          post '/serie_seasons', to: 'tv_series#serie_seasons', as: 'validated_serie_seasons'
          post '/season', to: 'seasons#my_posts_by_season', as: 'member_season'
          post '/posts_from_season', to: 'seasons#posts_from_season', as: 'member_posts_from_season'
          post '/delete_season', to: 'seasons#delete_season', as: 'validated_delete_season'
          post '/new_season', to: 'seasons#new_season', as: 'validated_new_season'
          post '/new_video', to: 'posts#new_video', as: 'validated_new_video'
          post '/my_series', to: 'tv_series#my_series', as: 'validated_my_series'
          post '/my_videos', to: 'posts#my_videos', as: 'validated_my_videos' # candidato a ser removido
          post '/my_categories', to: 'site#my_categories', as: 'validated_my_categories'
          post '/my_series_by_category', to: 'site#my_series_by_category', as: 'validated_my_series_by_category'
          post '/my_seasons_by_serie', to: 'tv_series#my_seasons_by_serie', as: 'validated_my_seasons_by_serie'

          get  '/my_library', to: 'posts#my_library', as: 'validated_my_library'
          post '/my_posts', to: 'posts#my_posts', as: 'validated_my_posts'
          post '/new_post', to: 'posts#new_post', as: 'validated_new_post'
          get  '/post/:id', to: 'posts#post', as: 'member_post'
          post '/post_information', to: 'posts#post_information', as: 'member_post_information'
          post '/serie_information', to: 'tv_series#serie_information', as: 'member_serie_information'
          post '/update_post', to: 'posts#update_post', as: 'validated_update_post'
          post '/delete_post', to: 'posts#delete_post', as: 'validated_delete_post'
          post '/delete_serie', to: 'tv_series#delete_tv_serie', as: 'validated_delete_serie'
          post '/update_serie', to: 'tv_series#update_serie', as: 'validated_update_serie'
          post '/new_vote', to: 'site#new_vote', as: 'member_new_vote'
          get  '/serie/:id', to: 'tv_series#serie', as: 'member_serie'

          post '/update_views', to: 'site#view_counter_update', as: 'member_view_counter_update'

          get  '/all_content', to: 'site#all_content', as: 'member_all_content'
          get  '/all_videos', to: 'posts#all_videos', as: 'member_all_videos'
          get  '/all_posts', to: 'posts#all_posts', as: 'member_all_posts'
          get  '/all_series', to: 'tv_series#all_series', as: 'member_all_series'
        end

        unauthenticated :member do
          root 'members/sessions#new', as: 'not_logged_member_root'
        end
      end
    end
  end
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
