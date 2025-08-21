# Rails.application.routes.draw do
#   get "messages/index"
#   get "chats/index"
#   # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

#   # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
#   # Can be used by load balancers and uptime monitors to verify that the app is live.
#   resources :products
#   root "products#index"




#   resources :applications
#   # get "/applications/:token", to: "applications#show"


Rails.application.routes.draw do
  resources :applications, param: :token do
    resources :chats, param: :chat_number do
      resources :messages, param: :message_number do
      collection do
        get "query", to: "messages#search"
      end
    end
    end
  end
end


#   get "up" => "rails/health#show", as: :rails_health_check




#   #   get "/products", to: "products#index"


#   # get "/products/new", to: "products#new"
#   # post "/products", to: "products#create"

#   # get "/products/:id", to: "products#show"

#   # get "/products/:id/edit", to: "products#edit"
#   # patch "/products/:id", to: "products#update"
#   # put "/products/:id", to: "products#update"

#   # delete "/products/:id", to: "products#destroy"







#   # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
#   # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
#   # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

#   # Defines the root path route ("/")
#   # root "posts#index"
# end
