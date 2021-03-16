# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/' => 'application#index'

  post '/provision' => 'addon#provision'
  put '/provision/:app_slug' => 'addon#update'
  delete '/provision/:app_slug' => 'addon#delete'

  post '/login' => 'use#login'

  get '/ascii-art/:app_slug' => 'provider#ascii_provider'
end
