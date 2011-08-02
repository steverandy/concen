module ControlCenter
  class UsersController < ApplicationController
    layout "control_center/application"

    before_filter :authenticate_user

    def index
      @users = User.all
    end

    def edit
      @user = current_user
    end

    def update
      @user = current_user
      if @user.authenticate(params[:control_center_user].delete(:current_password))
        if @user.update_attributes(params[:control_center_user])
          flash.now.alert = "Successfully update settings."
          redirect_to edit_control_center_user_path(@user)
        else
          flash.now.alert = "Failed to update settings."
          render :edit
        end
      else
        flash.now.alert = "Invalid password."
        render :edit
      end
    end
  end
end
