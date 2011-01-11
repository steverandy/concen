Rails.application.routes.draw do

  scope :constraints => {:subdomain => 'controlcenter'} do
    devise_for :admins, :class_name => 'ControlCenter::Admin', :path_names => { :sign_in => 'signin', :sign_out => 'signout', :sign_up => 'signup' }, :module => 'control_center/admins'
  end
  
  scope :constraints => {:subdomain => 'controlcenter'}, :as => 'control_center' do
    match '/' => 'control_center/main#index', :as => 'admin_root'
    match '/statistics' => 'control_center/main#statistics', :as => 'statistics'
    match '/content' => 'control_center/main#content', :as => 'content'
  end
  
  match '/visits/record.gif' => 'control_center/visits#record', :as => 'record_visit'
  match '/visits/js' => 'control_center/visits#visit_recorder_js', :as => 'visit_recorder_js'
  
end