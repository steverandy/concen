module ControlCenter
  class Referrer
    include Mongoid::Document
  
    embedded_in :visit_statistic, :inverse_of => :visit_statistics
  
    field :url, :type => String
    field :domain, :type => String
    field :count, :type => Integer, :default => 1
  end
end
