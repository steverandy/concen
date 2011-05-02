require "chronic"

module ControlCenter
  class ContentsController < ApplicationController
    layout "control_center/application"
    
    def index
      @content = Content.where(:level => 0).first
    end
    
    def new
      @content = Content.new
      @content.parent_id = BSON::ObjectId(params[:parent_id]) if params[:parent_id]
      @content.level = params[:level].to_i if params[:level]
    end
    
    def create
      @content = Content.new(params[:control_center_content])
      @content.parse_raw_text
      if @content.save
        redirect_to(edit_control_center_content_path(@content), :notice => "Content was successfully created.")
      else
        render :new
      end
    end
    
    def edit
      @content = Content.find(params[:id])
    end
    
    def update
      @content = Content.find(params[:id])
      if @content.update_attributes(params[:control_center_content])
        @content.parse_raw_text
        if @content.save
          redirect_to(edit_control_center_content_path(@content), :notice => "Content was successfully created.")
        else
          render :edit
        end
      else
        render :edit
      end
    end
    
    def destroy
      @content = Content.find(params[:id])
      @content.destroy
      redirect_to control_center_contents_path
    end
    
    def upload_file
      # logger.info { "----#{env['rack.input']}" }
      # 
      # logger.info { "----#{env['HTTP_X_FILE_NAME']}" }
      # logger.info { "----#{env['CONTENT_TYPE']}" }
      @content = Content.find(params[:id])
      @file = @content.grid_files.build
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
