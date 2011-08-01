module ControlCenter
  class MainController < ApplicationController
    layout "control_center/application"

    # before_filter :authenticate_user

    def index
      redirect_to :action => :statistics
    end

    def assets
    end
  end
end
