module ControlCenter
  class Page
    include Mongoid::Document
    include Mongoid::Timestamps
    
    embeds_many :grid_files, :class_name => "ControlCenter::GridFile"

    field :parent_id, :type => BSON::ObjectId
    field :level, :type => Integer
    field :title, :type => String
    field :description, :type => String
    field :default_slug, :type => String
    field :content, :type => String
    field :raw_text, :type => String
    field :position, :type => Integer
    field :publish_time, :type => Time
    field :labels, :type => Array, :default => []
    
    validates_presence_of :title
    validates_presence_of :default_slug
    validates_uniqueness_of :title, :scope => [:parent_id, :level], :case_sensitive => false
    validates_uniqueness_of :default_slug, :scope => [:parent_id, :level], :case_sensitive => false
    
    before_validation :set_default_slug
    before_create :set_position
    before_destroy :destroy_children
    before_destroy :destroy_grid_files
    after_destroy :reset_position
    
    scope :with_position, where(:position.exists => true)
    
    PROTECTED_FIELDS = [:parent_id, :level, :default_slug, :content, :raw_text, :position]
    
    def children
      Page.where(:parent_id => self.id)
    end
    
    def parent
      Page.find(self.parent_id)
    end
    
    def images(filename=nil)
      search_grid_files(["png", "jpg", "jpeg", "gif"], filename)
    end
    
    def stylesheets(filename=nil)
      search_grid_files(["css"], filename)
    end
    
    def javascripts(filename=nil)
      search_grid_files(["js"], filename)
    end
    
    def search_grid_files(extensions, filename=nil)
      if filename
        self.grid_files.where(:original_filename => /.*#{filename}.*.*\.(#{extensions.join("|")}).*$/i)
      else
        self.grid_files.where(:original_filename => /.*\.(#{extensions.join("|")}).*/i)
      end
    end
    
    def parse_raw_text
      raw_text_array = self.raw_text.split("---")
      if raw_text_array.count > 0
        meta_data = raw_text_array.first.strip.split("\r\n\r\n")
        self.content = raw_text_array.last.strip
      else
        meta_data = self.raw_text.strip.split("\r\n\r\n")
        self.content = nil
      end
      for data in meta_data
        key = data.split(":").first.gsub(" ","").underscore.to_sym
        value = data.split(":").last.strip
        unless ControlCenter::Page::PROTECTED_FIELDS.include?(key)
          if key == :publish_time
            self.parse_publish_time(value)
          elsif key == :labels
            self.parse_labels(value)
          else
            self[key] = value
          end
        end
      end
    end
    
    def parse_publish_time(publish_time_string)
      begin
        Chronic.time_class = Time.zone
        parsed_date = Chronic.parse(publish_time_string, :now => Time.zone.now)
      rescue
        parsed_date = nil
      end
      if parsed_date
        self.publish_time = parsed_date
      elsif parsed_date = Time.zone.parse(publish_time_string)
        self.publish_time = parsed_date
      end
    end
    
    def parse_labels(labels_string)
      labels_string.split(",").each do |label|
        self.labels << label.strip
      end
    end
    
    protected
    
    def set_default_slug
      self.default_slug = self.title.parameterize if self.title
    end
    
    def set_position
      if Page.where(:level => self.level).count > 0
        self.position = Page.with_position.where(:level => self.level).asc(:position).last.position + 1
      else
        self.position = 1
      end
    end

    def reset_position
      affected_pages = Page.with_position.where(:level => self.level, :position.gt => self.position)
      if affected_pages.count > 0
        for page in affected_pages
          page.position = page.position - 1
          page.save
        end
      end
    end
    
    def destroy_children
      for child in Page.where(:parent_id => self.id)
        child.destroy
      end
    end
    
    def destroy_grid_files
      for grid_file in self.grid_files
        grid_file.destroy
      end
    end
  end
end
