module ControlCenter
  class Admins::SessionsController < ApplicationController
    prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
    include Devise::Controllers::InternalHelpers
    
    layout "control_center/application"

    # GET /resource/sign_in
    def new
      clean_up_passwords(build_resource)
      render_with_scope :new
    end
    
    def create
      resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => redirect_location(resource_name, resource)
    end
    
    def destroy
      signed_in = signed_in?(resource_name)
      sign_out_and_redirect(resource_name)
      set_flash_message :notice, :signed_out if signed_in
    end
  end
end
