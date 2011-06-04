module ControlCenter
  class GridFile
    include Mongoid::Document
    include Mongoid::Timestamps
  
    embedded_in :page, :class_name => "ControlCenter::Page"
  
    field :filename, :type => String
    field :original_filename, :type => String
    field :private, :type => Boolean
    field :grid_id, :type => BSON::ObjectId
    
    before_destroy :destroy_gridfs
    
    def path
      "/gridfs/" + self.filename
    end
    
    def read
      grid = Mongo::Grid.new(Mongoid.database)
      grid.get(self.grid_id).read
    end
    
    def text?
      grid = Mongo::Grid.new(Mongoid.database)
      grid.get(self.grid_id).content_type.include?("text") || grid.get(self.grid_id).content_type.include?("javascript")
    end
    
    def store(content, filename)
      original_filename = filename.dup
      file_extension = File.extname(filename).downcase
      filename = "#{self.id.to_s}-#{File.basename(original_filename, file_extension).parameterize.gsub("_", "-")}#{file_extension}"
      grid = Mongo::Grid.new(Mongoid.database)
      content_type = MIME::Types.type_for(filename).first.to_s
      if self.grid_id
        grid.delete(self.grid_id)
      end
      if grid_id = grid.put(content, :content_type => content_type, :filename => filename, :safe => true)
        self.update_attributes(:filename => filename, :original_filename => original_filename, :grid_id => grid_id)
      end
    end
    
    def destroy_gridfs
      grid = Mongo::Grid.new(Mongoid.database)
      grid.delete(self.grid_id)
    end
  end
end