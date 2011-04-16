module ControlCenter
  class File
    include Mongoid::Document
    include Mongoid::Timestamps
  
    embedded_in :page
  
    field :filename, :type => String
    field :private, :type => Boolean
    field :gridfs_id, :type => BSON::ObjectId
  
    def path
      # GRIDFS_PATH + self.filename
      self.filename
    end
  end
end