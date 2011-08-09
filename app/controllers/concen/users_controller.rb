module Concen
  class UsersController < ApplicationController
    layout "concen/application"

    before_filter :authenticate_concen_user

    def index
      @users = User.all
    end

    def edit
      @user = current_concen_user
    end

    def update
      @user = current_concen_user
      if @user.authenticate(params[:concen_user].delete(:current_password))
        if @user.update_attributes(params[:concen_user])
          flash.now.alert = "Successfully update settings."
          redirect_to edit_concen_user_path(@user)
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
