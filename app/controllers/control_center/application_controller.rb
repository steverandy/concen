module ControlCenter
  class ApplicationController < ActionController::Base
    protect_from_forgery

    layout "control_center/application"

    before_filter :set_controlcenter

    helper_method :current_user, :authenticate_user

    protected

    def set_controlcenter
      @controlcenter = true
    end

    def current_user
      @current_user ||= ControlCenter::User.where(:auth_token => cookies[:auth_token]).first if cookies[:auth_token]
    end

    def authenticate_user
      redirect_to control_center_signin_path unless current_user
    end
  end
end
