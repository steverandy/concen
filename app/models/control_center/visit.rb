module ControlCenter
  class Visit
    include Mongoid::Document
  
    field :url, :type => String
    field :ip_address, :type => String
    field :user_agent, :type => String
    field :visitor_id, :type => String
    field :timestamp, :type => Time
    field :screen_width, :type => Integer
    field :screen_height, :type => Integer
    field :referrer_url, :type => String
    field :referrer_domain, :type => String
    field :os, :type => String
    field :browser, :type => String
    field :browser_version, :type => String
  
    index :url
    index :timestamp
    index :visitor_id
  end
end
