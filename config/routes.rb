Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post   '/provision'         => 'application#provision'
  put    '/provision/:slug'   => 'application#change_plan'
  delete '/provision/:slug'   => 'application#deprovision'
  get    '/login'             => 'application#login'
end
