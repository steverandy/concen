module Concen
  class ApplicationController < ActionController::Base
    protect_from_forgery

    before_filter :set_concen

    helper_method :current_concen_user, :authenticate_concen_user

    protected

    def set_concen
      @concen = true
    end

    def current_concen_user
      @current_concen_user ||= User.where(:auth_token => cookies[:auth_token]).first if cookies[:auth_token]
    end

    def authenticate_concen_user
      redirect_to concen_signin_path unless current_concen_user
    end
  end
end
