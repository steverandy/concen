require "concen/engine" if defined?(Rails)

module Concen
  mattr_accessor :application_name, :typekit_id, :markdown_extensions, :parse_markdown_with_smartypants
  @@application_name = nil
  @@typekit_id = "qxq7sbk"
  @@markdown_extensions = {}
  @@parse_markdown_with_smartypants = true

  def self.setup
    yield self
  end
end
