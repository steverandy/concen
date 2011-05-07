module ControlCenter
  class GridFilesController < ApplicationController
    layout "control_center/application"
    
    def edit
      @page = Page.find(params[:page_id])
      @grid_file = @page.grid_files.find(params[:id])
    end
    
    def update
      @page = Page.find(params[:page_id])
      @grid_file = @page.grid_files.find(params[:id])
      if @grid_file.store(params[:control_center_grid_file_page], @grid_file.original_filename)
        redirect_to edit_control_center_page_grid_file_path(@page, @grid_file)
      else
        render :edit
      end
    end
    
    def destroy
      @page = Page.find(params[:page_id])
      @grid_file = @page.grid_files.find(params[:id])
      @grid_file.destroy
      redirect_to edit_control_center_page_path(@page)
    end
  end
end
