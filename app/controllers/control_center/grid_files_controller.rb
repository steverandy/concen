module ControlCenter
  class GridFilesController < ApplicationController
    layout "control_center/application"
    
    def edit
      @content = Content.find(params[:content_id])
      @grid_file = @content.grid_files.find(params[:id])
    end
    
    def update
      @content = Content.find(params[:content_id])
      @grid_file = @content.grid_files.find(params[:id])
      if @grid_file.store(params[:control_center_grid_file_content], @grid_file.original_filename)
        redirect_to edit_control_center_content_grid_file_path(@content, @grid_file)
      else
        render :edit
      end
    end
    
    def destroy
      @content = Content.find(params[:content_id])
      @grid_file = @content.grid_files.find(params[:id])
      @grid_file.destroy
      redirect_to edit_control_center_content_path(@content)
    end
  end
end
