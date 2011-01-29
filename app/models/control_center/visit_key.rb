module ControlCenter
  class VisitKey
    include Mongoid::Document

    field :expire, :type => Time
  end
end
