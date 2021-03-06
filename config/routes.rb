Rails.application.routes.draw do
  resources :info, only: [:index]
  resources :termsofservice, only: [:index]
  resources :privacypolicy, only: [:index]
  
  get 'villages/show'
  get 'village/show'
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations'
  }

  resources :comment1s
  resources :themes
  resources :rooms do
  	collection do
  	  put 'join'
  	  get 'judge'
  	  get 'room_out'
  	end
  end
  resources :villages do
  	collection do
  	  put 'create'
  	  get 'modal_trigger_show'
  	  put 'resend_show_village'
  	  put 'notif_result_village'
  	end
  end
  
  get 'selectroom/index'
  get 'welcome/index'
  get 'home/index'
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
