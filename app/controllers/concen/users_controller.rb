module Concen
  class UsersController < ApplicationController
    layout "concen/application"

    before_filter :authenticate_concen_user, :except => [:new, :edit, :update, :create, :new_reset_password, :reset_password]

    def index
      @page_title = "Users"
      @users = User.all
    end

    def new
      if User.all.any?
        redirect_to root_path
      else
        @user = User.new
      end
    end

    def create
      if !User.all.any? || (current_concen_user && current_concen_user.full_control)
        @user = User.new(params[:concen_user])
        @user.full_control = true
        if @user.save
          redirect_to(concen_users_path, :notice => "User was successfully created.")
        else
          render :new
        end
      end
    end

    def edit
      if params[:password_reset_token]
        @user = User.where(:password_reset_token => params[:password_reset_token]).first
      elsif params[:invitation_token]
        @user = User.where(:invitation_token => params[:invitation_token]).first
      else
        @page_title = "Settings"
        @user = current_concen_user
      end
      redirect_to concen_signin_path unless @user
    end

    def update
      if params[:concen_user][:password_reset_token]
        @user = User.where(:password_reset_token => params[:concen_user][:password_reset_token]).first
        authenticated = true if @user.password_reset_sent_at > 2.hours.ago
      elsif params[:concen_user][:invitation_token]
        @user = User.where(:invitation_token => params[:concen_user][:invitation_token]).first
        authenticated = true if @user.invitation_sent_at > 24.hours.ago
      else
        @user = current_concen_user
        authenticated = true if @user.authenticate(params[:concen_user].delete(:current_password))
      end
      if @user && authenticated
        if @user.update_attributes(params[:concen_user])
          redirect_to edit_concen_user_path @user
        else
          render :edit
        end
      else
        flash.now.alert = "Invalid password."
        render :edit
      end
    end

    def destroy
      if current_concen_user.full_control
        @user = User.find(params[:id])
        @user.destroy
        redirect_to concen_users_path
      else
        flash[:notice] = "Only user with full control can delete a user."
        redirect_to concen_users_path
      end
    end

    def toggle_attribute
      respond_to do |format|
        if current_concen_user.full_control
          @user = User.find(params[:id])
          @user.write_attribute(params[:attribute].to_sym, !@user.read_attribute(params[:attribute].to_sym))
          @user.save
          format.json { render :json => {:success => true} }
        else
          format.json { render :json => {:success => false, :message => "Only user with full control can toggle attribute."} }
        end
      end
    end

    def new_invite
      if current_concen_user.full_control
        @user = User.new
      else
        redirect_to(concen_users_path, :notice => "Only user with full control can invite.")
      end
    end

    def invite
      if current_concen_user.full_control
        @user = User.send_invitation params[:concen_user][:email]
        redirect_to concen_users_path, :notice => "Invitation has been sent."
      else
        redirect_to concen_users_path, :notice => "Only user with full control can invite."
      end
    end

    def new_reset_password
      @user = User.new
    end

    def reset_password
      @user = User.where(:email => params[:concen_user][:email]).first
      @user.send_password_reset
      redirect_to concen_signin_path, :notice => "Password reset instruction has been sent."
    end
  end
end
