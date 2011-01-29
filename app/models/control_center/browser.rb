module ControlCenter
  class Browser
    include Mongoid::Document
  
    embedded_in :visit_statistic, :inverse_of => :visit_statistics
  
    field :name, :type => String
    field :version, :type => String
    field :count, :type => Integer, :default => 1
  end
end
