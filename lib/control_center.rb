require "control_center/engine" if defined?(Rails)

module ControlCenter
  mattr_accessor :application_name
  @@application_name = nil

  def self.setup
    yield self
  end
end
