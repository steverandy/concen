require "concen/engine" if defined?(Rails)

module Concen
  mattr_accessor :application_name, :typekit_id
  @@application_name = nil
  @@typekit_id = "qxq7sbk"

  def self.setup
    yield self
  end
end
