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
      parse_content
      if @page.save
        redirect_to(control_center_pages_path, :notice => "{Page was successfully created.") 
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
        parse_content
        if @page.save
          redirect_to control_center_pages_path
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
      logger.info { "----#{env['rack.input']}" }
      logger.info { "----#{env['HTTP_X_FILE_NAME']}" }
      logger.info { "----#{env['CONTENT_TYPE']}" }
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
    
    def parse_content
      meta_data = @page.content.split("---").first
      @page.title = meta_data.split("Title: ").last.split("\r\n").first
      @page.description = meta_data.split("Description: ").last.split("\r\n").first
      publish_time_string = meta_data.split("Publish Time: ").last.split("\r\n").first
      begin
        Chronic.time_class = Time.zone
        parsed_date = Chronic.parse(publish_time_string, :now => Time.zone.now)
      rescue
        parsed_date = nil
      end
      if parsed_date
        @page.publish_time = parsed_date
      elsif parsed_date = Time.zone.parse(publish_time_string)
        @page.publish_time = parsed_date
      end
    end
  end
end
