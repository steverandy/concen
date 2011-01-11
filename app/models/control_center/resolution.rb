module ControlCenter
  class Resolution
    include Mongoid::Document
  
    embedded_in :visit_statistic, :inverse_of => :visit_statistics
  
    field :screen_width, :type => Integer
    field :screen_height, :type => Integer
    field :count, :type => Integer, :default => 1
  end
end