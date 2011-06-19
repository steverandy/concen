module ControlCenter
  class GridFilesController < ApplicationController
    layout "control_center/application"

    def new
      @page = Page.find(params[:page_id])
      @grid_file = @page.grid_files.build
    end

    def create
      @page = Page.find(params[:page_id])
      @grid_file = @page.grid_files.build
      filename = params[:filename]
      if ["css", "js"].include?(params[:file_type])
        unless MIME::Types.type_for(filename).first.to_s.include?(params[:file_type])
          filename << "." + params[:file_type]
        end
      end
      if @grid_file.store("", filename)
        content = render_to_string(:partial => "control_center/pages/files")
        render :json => {:success => true, :content => content}
      else
        render :json => {:success => false}
      end
    end

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

    def upload
      # logger.info { "----#{env['rack.input']}" }
      # logger.info { "----#{env['HTTP_X_FILE_NAME']}" }
      # logger.info { "----#{env['CONTENT_TYPE']}" }
      @page = Page.find(params[:page_id])
      @grid_file = @page.grid_files.build
      if env["rack.input"]
        file = env["rack.input"]
        filename = env["HTTP_X_FILE_NAME"]
      else
        file = params[:qqfile].read
        filename = params[:qqfile].original_filename
      end
      if @grid_file.store(file, filename)
        content = render_to_string(:partial => "control_center/pages/files")
        render :json => {:success => true, :content => content}
      end
    end
  end
end
