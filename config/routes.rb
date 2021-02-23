Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'submissions#index'
  post '/', to: 'submissions#index'
  # root 'homes#show'

  resource :login

  resource :submission
end
