require "chronic"

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
      @page.parse_raw_text
      if @page.save
        redirect_to(edit_control_center_page_path(@page), :notice => "{Page was successfully created.")
      else
        render :new
      end
    end
    
    def edit
      @page = Page.find(params[:id])
    end
    
    def update
      @page = Page.find(params[:id])
      if @page.update_attributes(params[:control_center_page])
        @page.parse_raw_text
        if @page.save
          redirect_to(edit_control_center_page_path(@page), :notice => "{Page was successfully created.")
        else
          render :edit
        end
      else
        render :edit
      end
    end
    
    def destroy
      @page = Page.find(params[:id])
      @page.destroy
      redirect_to control_center_pages_path
    end
    
    def upload_file
      # logger.info { "----#{env['rack.input']}" }
      # logger.info { "----#{env['HTTP_X_FILE_NAME']}" }
      # logger.info { "----#{env['CONTENT_TYPE']}" }
      @page = Page.find(params[:id])
      @file = @page.grid_files.build
      if env['rack.input']
        @file.store(env['rack.input'], env['HTTP_X_FILE_NAME'])
      else
        @file.store(params[:qqfile].read, params[:qqfile].original_filename)
      end
      if @file.save
        render :text => "{'success': true}"
      end
    end
  end
end
