module ControlCenter
  class VisitKey
    include Mongoid::Document

    store_in "control_center.visit_keys"

    field :expire, :type => Time
  end
end
