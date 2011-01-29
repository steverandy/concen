module ControlCenter
  class Location
    include Mongoid::Document
  
    embedded_in :visit_statistic, :inverse_of => :visit_statistics
  
    field :country_code, :type => String
    field :country, :type => String
    field :count, :type => Integer, :default => 1
  end
end
