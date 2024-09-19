Rails.application.routes.draw do
  resources :events, except: %i[new update edit]

  resources :organizations, shallow: true do
    resources :events
  end

  get 'events/:id/edit_photos', to: 'events#edit_photos', as: :edit_event_photos

  resources :photos
  resources :galleries, shallow: true do
    resources :photos
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'organizations#index'
  post '/search_galleries', to: 'galleries#search', as: :gallery_search
end
