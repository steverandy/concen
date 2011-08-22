require "rack/gridfs"

# Use Rails.application.routes.prepend on Rails 3.1.
Rails.application.routes.draw do
  match "/visits/record.gif" => "concen/visits#record", :as => "record_visit"
  match "/visits/js" => "concen/visits#visit_recorder_js", :as => "visit_recorder_js"

  scope :constraints => {:subdomain => "concen"}, :module => "concen", :as => "concen"  do
    get "signout" => "sessions#destroy", :as => "signout"
    get "signin" => "sessions#new", :as => "signin"
    get "signup" => "users#new", :as => "signup"

    resources :users do
      collection do
        get :new_invite
        post :invite
        get :new_reset_password
        post :reset_password
      end
      member do
        put :toggle_attribute
      end
    end

    resources :sessions

    resource :status do
      member do
        get :server
        get :counts
      end
    end

    resource :traffic do
      member do
        get :visits_counts
        get :pages
        get :referrals
      end
    end

    resource :performance do
      member do
        get :responses
        get :runtimes
      end
    end

    resources :pages do
      collection do
        put :sort
      end

      resources :grid_files do
        collection do
          post :upload
        end
      end
    end

    root :to => "statuses#show"
  end

  begin
    mount Rack::GridFS::Endpoint.new(:db => Mongoid.database, :lookup => :path, :expires => 315360000), :at => "gridfs"
  rescue; end;
end
