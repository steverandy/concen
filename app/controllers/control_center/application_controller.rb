module ControlCenter
  class ApplicationController < ActionController::Base
    protect_from_forgery
  
    before_filter :authenticate_admin!
    before_filter :get_user_agent
    before_filter :set_admin_time_zone
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
  
    def set_admin_time_zone
      Time.zone = current_admin.time_zone if admin_signed_in?
    end
  end
end