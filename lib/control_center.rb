require "control_center/engine" if defined?(Rails)

module ControlCenter    
  mattr_accessor :application_name, :geoip_api_key
  @@application_name = nil
  @@geoip_api_key = nil

  def self.setup
    yield self
  end 
end