module ControlCenter
  class ApplicationController < ActionController::Base
    protect_from_forgery
    
    layout "control_center/application"
  
    before_filter :get_user_agent
    before_filter :set_controlcenter
  
    helper_method :ios?
  
    def ios?
      if @user_agent.os.to_s == "iOS"
        return true
      else
        return false
      end
    end
  
    protected
    
    def get_user_agent
      @user_agent = Agent.new request.env["HTTP_USER_AGENT"]
    end
  
    def set_controlcenter
      @controlcenter = true
    end
  end
end
