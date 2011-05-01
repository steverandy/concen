# This controller mostly will be used in development mode.
# In the production mode, serving files from GridFS should 
# be done through Nginx GridFS module.

require "mongo"

module ControlCenter
  class GridfsController < ActionController::Metal
    def serve
      gridfs_path = env["PATH_INFO"].gsub("/gridfs/", "")
      begin
        gridfs_file = Mongo::GridFileSystem.new(Mongoid.database).open(gridfs_path, 'r')
        self.response_body = gridfs_file.read
        self.content_type = gridfs_file.content_type
      rescue
        self.status = :not_found
        self.content_type = 'text/plain'
        self.response_body = ''
      end
    end
  end
end