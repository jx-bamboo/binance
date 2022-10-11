Rails.application.routes.draw do

  root "home#index"
  resources :clients do
    collection do
      get "control"
      get "get_control"
      post "post_control"
      get "vip"
      get "two_auth"
      get "two"
      post "two_deal"
      get "check_two_auth"
      post "deal_two_auth"
      get "deal_two_auth"
	    post "cancle_all_order"
			post "cancle_order"
    end
  end
  devise_for :users
  # devise_for :users, controllers: {
  #   sessions: 'users/sessions'
  # }

  get "/home/two", to: "home#two"

  # get 'two_auth', to: 'devise/sessions#two_auth'
	
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
