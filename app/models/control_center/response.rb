module ControlCenter
  class Response
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in self.name.underscore.gsub("/", ".").pluralize
  end
end
