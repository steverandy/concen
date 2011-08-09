require "concen/engine" if defined?(Rails)

module Concen
  mattr_accessor :application_name
  @@application_name = nil

  def self.setup
    yield self
  end
end
