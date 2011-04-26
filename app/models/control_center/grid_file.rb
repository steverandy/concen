module ControlCenter
  class GridFile
    include Mongoid::Document
    include Mongoid::Timestamps
  
    embedded_in :page
  
    field :filename, :type => String
    field :private, :type => Boolean
    field :grid_id, :type => BSON::ObjectId
  
    def path
      # GRIDFS_PATH + self.filename
      self.filename
    end
    
    def store(content, filename)
      grid = Mongo::Grid.new(Mongoid.database)
      file_extension = File.extname(filename).downcase
      content_type = MIME::Types.type_for(filename).first.to_s

      if grid_id = grid.put(content, :content_type => content_type, :filename => filename, :safe => true)
        self.update_attributes(:filename => filename, :grid_id => grid_id)
      end
    end
  end
end