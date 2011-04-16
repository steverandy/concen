module ControlCenter
  class PagesController < ApplicationController
    layout "control_center/application"
    
    def index
      @home_page = Page.where(:level => 0).first
    end
    
    def new
      @page = Page.new
      @page.parent_id = BSON::ObjectId(params[:parent_id]) if params[:parent_id]
      @page.level = params[:level].to_i if params[:level]
    end
    
    def create
      @page = Page.new(params[:control_center_page])
      if @page.save
        redirect_to(control_center_pages_path, :notice => "{Page was successfully created.") 
      else
        render :new
      end
    end
    
    def edit
      
    end
    
    def update
      
    end
    
    def destroy
      
    end
  end
end
