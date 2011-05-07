require "chronic"

module ControlCenter
  class PagesController < ApplicationController
    layout "control_center/application"
    
    def index
      @page = Page.where(:level => 0).first
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
        redirect_to(edit_control_center_page_path(@page), :notice => "Page was successfully created.")
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
          redirect_to(edit_control_center_page_path(@page), :notice => "Page was successfully created.")
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
      render :json => {:success => true} if @file.save
    end
    
    def sort
      if params[:page]
        child_count = {}
        params[:page].each do |key, value|
          if value == "root"
            root = Page.find(key)
            root.parent_id = nil
            root.level = 0
            root.save
          else
            child = Page.find(key)
            parent = Page.find(value)
            child.parent_id = parent.id
            child.level = parent.level + 1
            if child_count[value]
              child.position = child_count[value] + 1
              child_count[value] += 1
            else
              child.position = 1
              child_count[value] = 1
            end
            child.save
          end
        end
        render :json => {:success => true}
      end
    end
  end
end
