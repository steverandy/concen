module ControlCenter

  class OperatingSystem
  
    include Mongoid::Document
  
    embedded_in :visit_statistic, :inverse_of => :visit_statistics
  
    field :name, :type => String
    field :count, :type => Integer, :default => 1
  
  end

end