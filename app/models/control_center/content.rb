require "yaml"

module ControlCenter
  class Content
    include Mongoid::Document
    include Mongoid::Timestamps
    
    embeds_many :grid_files, :class_name => "ControlCenter::GridFile"

    field :parent_id, :type => BSON::ObjectId
    field :level, :type => Integer
    field :title, :type => String
    field :description, :type => String
    field :default_slug, :type => String
    field :raw_text, :type => String
    field :markup, :type => String
    field :position, :type => Integer
    field :publish_time, :type => Time
    field :labels, :type => Array, :default => []
    field :authors, :type => Array, :default => []
    
    validates_presence_of :title
    validates_presence_of :default_slug
    validates_uniqueness_of :title, :scope => [:parent_id, :level], :case_sensitive => false
    validates_uniqueness_of :default_slug, :scope => [:parent_id, :level], :case_sensitive => false
    
    before_validation :set_default_slug
    before_create :set_position
    after_save :unset_unused_dynamic_fields
    before_destroy :destroy_children
    before_destroy :destroy_grid_files
    after_destroy :reset_position
    
    scope :with_position, where(:position.exists => true)
    
    # Get the list of dynamic fields by checking againts this array.
    # Values should mirror the listed fields above.
    PREDEFINED_FIELDS = [:_id, :created_at, :updated_at, :parent_id, :level, :title, :description, :default_slug, :raw_text, :markup, :position, :publish_time, :labels, :authors]
    
    # These fields can't be overwritten by user's meta data when parsing raw_text.
    PROTECTED_FIELDS = [:_id, :parent_id, :level, :default_slug, :content, :raw_text, :position]
    
    def children
      Content.where(:parent_id => self.id)
    end
    
    def parent
      Content.find(self.parent_id)
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
      if raw_text_array.count > 1
        meta_data = raw_text_array.first.strip
        self.markup = raw_text_array.last.strip
      else
        meta_data = self.raw_text.strip
        self.markup = nil
      end
      meta_data = underscore_hash_keys(YAML.load(meta_data))
      meta_data.each do |key, value|
        unless ControlCenter::Content::PROTECTED_FIELDS.include?(key)
          if key == :publish_time
            self.parse_publish_time(value)
          else
            self[key] = value
          end
        end
      end
      (self.attributes.keys.map{ |k| k.to_sym } - PREDEFINED_FIELDS).each do |field|
        self[field] = nil if !meta_data.keys.include?(field)
      end
    end
    
    def underscore_hash_keys(hash)
      new_hash = {}
      hash.each do |key, value|        
        value = underscore_hash_keys(value) if value.is_a?(Hash)
        new_hash[key.gsub(" ","_").downcase.to_sym] = value
      end
      new_hash
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
    
    protected
    
    def set_default_slug
      self.default_slug = self.title.parameterize if self.title
    end
    
    def set_position
      if Content.where(:level => self.level).count > 0
        self.position = Content.with_position.where(:level => self.level).asc(:position).last.position + 1
      else
        self.position = 1
      end
    end

    def reset_position
      affected_contents = Content.with_position.where(:level => self.level, :position.gt => self.position)
      if affected_contents.count > 0
        for content in affected_contents
          content.position = content.position - 1
          content.save
        end
      end
    end
    
    def destroy_children
      for child in Content.where(:parent_id => self.id)
        child.destroy
      end
    end
    
    def destroy_grid_files
      for grid_file in self.grid_files
        grid_file.destroy
      end
    end
    
    def unset_unused_dynamic_fields
      target_fields = {}
      for field in self.attributes.keys
        if !PREDEFINED_FIELDS.include?(field.to_sym) && self[field.to_sym].nil?
          target_fields[field.to_s] = 1
        end
      end
      Content.collection.update({"_id" => self.id}, {"$unset" => target_fields})
    end
  end
end
