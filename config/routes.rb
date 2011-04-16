Rails.application.routes.draw do  
  scope :constraints => {:subdomain => "controlcenter"}, :as => "control_center" do
    match "/statistics" => "control_center/main#statistics", :as => "statistics"
    match "/content" => "control_center/main#content", :as => "content"
  end
  
  match "/visits/record.gif" => "control_center/visits#record", :as => "record_visit"
  match "/visits/js" => "control_center/visits#visit_recorder_js", :as => "visit_recorder_js"
end