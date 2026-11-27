Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :funds, only: %i[index]

      resources :donations, only: %i[show create]
    end
  end

  # Stripe webhook listener (kept outside /api/v1 so Stripe URLs remain static across API versions)
  namespace :webhooks do
    post :stripe, to: "stripe#create"
  end
end
