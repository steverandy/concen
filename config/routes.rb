Rails.application.routes.draw do  
  scope :constraints => {:subdomain => "controlcenter"}, :module => "control_center", :as => "control_center"  do
    match "/statistics" => "main#statistics", :as => "statistics"
    resources :pages do
      member do
        post :upload_file
      end
    end
    root :to => "main#statistics"
  end
  
  match '/gridfs/*path' => 'control_center/gridfs#serve' unless Rails.env == 'production'
  match "/visits/record.gif" => "control_center/visits#record", :as => "record_visit"
  match "/visits/js" => "control_center/visits#visit_recorder_js", :as => "visit_recorder_js"
end