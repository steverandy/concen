module ControlCenter
  class VisitKey
    include Mongoid::Document

    store_in self.name.underscore.gsub("/", ".").pluralize

    field :expire, :type => Time
  end
end
