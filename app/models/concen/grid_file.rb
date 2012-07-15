module Concen
  class GridFile
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :page, :class_name => "Concen::Page"

    field :filename, :type => String
    field :original_filename, :type => String
    field :private, :type => Boolean
    field :grid_id, :type => BSON::ObjectId

    validates_presence_of :filename
    validates_presence_of :original_filename
    validates_presence_of :grid_id

    after_destroy :destroy_gridfs

    def path
      "/gridfs/" + self.filename
    end

    def url(root_url)
      root_url.gsub!("concen.", "") # Remove concen subdomain.
      root_url = root_url[0..-2] # Remove trailing slash.
      root_url + self.path
    end

    def read
      grid = Mongo::Grid.new(Mongoid.database)
      grid.get(self.grid_id).read
    end

    def size
      grid = Mongo::Grid.new(Mongoid.database)
      grid.get(self.grid_id).file_length
    end

    def text?
      grid = Mongo::Grid.new(Mongoid.database)
      grid.get(self.grid_id).content_type.include?("text") || grid.get(self.grid_id).content_type.include?("javascript")
    end

    def store(content, filename)
      grid = Mongo::Grid.new(Mongoid.database)

      # First, delete if a GridFS file already exists.
      # There is no update.
      grid.delete(self.grid_id) if self.grid_id

      original_filename = filename.dup
      file_extension = File.extname(original_filename).downcase
      content_type = content_type_for original_filename

      # Pre generate ObjectId for the new GridFS file.
      grid_id = BSON::ObjectId.new

      filename = File.basename(original_filename, file_extension).downcase.parameterize.gsub("_", "-")
      filename = "#{grid_id.to_s}-#{filename}#{file_extension}"

      if grid.put(content, :_id => grid_id, :filename => filename, :content_type => content_type, :safe => true)
        self.update_attributes(:grid_id => grid_id, :filename => filename, :original_filename => original_filename)
      else
        return false
      end
    end

    def content_type_for(filename)
      content_type = MIME::Types.type_for(filename).first.to_s

      # Special cases when mime-types fails to recognize
      content_type = "video/mp4" if filename.include?(".mp4")
      content_type = "video/x-m4v" if filename.include?(".m4v")

      return content_type
    end

    protected

    def destroy_gridfs
      grid = Mongo::Grid.new(Mongoid.database)
      grid.delete(self.grid_id)
    end
  end
end
