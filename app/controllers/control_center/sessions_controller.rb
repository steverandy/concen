require "chronic"

module ControlCenter
  class SessionsController < ApplicationController
    layout "control_center/application"

    def new
    end

    def create
      user = User.where(:username => params[:username]).first
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to root_path, :notice => "You have successfully signed in!"
      else
        flash.now.alert = "Invalid email or password"
        render "new"
      end
    end

    def destroy
      session[:user_id] = nil
      redirect_to root_path, :notice => "You have successfully signed out!"
    end
  end
end
