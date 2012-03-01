module Concen
  class SessionsController < Concen::ApplicationController
    def new
      if User.all.any?
        render
      else
        redirect_to new_concen_user_path
      end
    end

    def create
      user = User.where(:username => /#{params[:username]}/i).first

      if user && user.authenticate(params[:password])
        cookies.permanent[:auth_token] = user.auth_token
        redirect_to concen_root_path, :notice => "You have successfully signed in!"
      else
        flash.now.alert = "Invalid email or password"
        render "new"
      end
    end

    def destroy
      cookies.delete(:auth_token)
      redirect_to root_path, :notice => "You have successfully signed out!"
    end
  end
end
