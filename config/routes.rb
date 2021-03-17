# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/' => 'application#index'

  post '/provision' => 'addon#provision'
  delete '/provision/:app_slug' => 'addon#delete'

  post '/login' => 'user#login'

  get '/ascii-art/:app_slug' => 'provider#ascii_provider'
end
