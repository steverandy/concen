require "yaml"
require "redcarpet"

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
    field :raw_text, :type => String
    field :content, :type => String
    field :position, :type => Integer
    field :publish_time, :type => Time
    field :publish_month, :type => Time
    field :labels, :type => Array, :default => []
    field :authors, :type => Array, :default => []
    
    validates_presence_of :title
    validates_presence_of :default_slug
    validates_uniqueness_of :title, :scope => [:parent_id, :level], :case_sensitive => false
    validates_uniqueness_of :default_slug, :scope => [:parent_id, :level], :case_sensitive => false
    
    before_validation :set_default_slug
    before_save :set_publish_month
    before_create :set_position
    after_save :unset_unused_dynamic_fields
    before_destroy :destroy_children
    before_destroy :destroy_grid_files
    after_destroy :reset_position
    
    scope :with_position, where(:position.exists => true)
    scope :published, lambda { {:where => {:publish_time.lte => Time.now.utc}} }
    
    # Get the list of dynamic fields by checking againts this array.
    # Values should mirror the listed fields above.
    PREDEFINED_FIELDS = [:_id, :parent_id, :level, :created_at, :updated_at, :default_slug, :content, :raw_text, :position, :grid_files, :title, :description, :publish_time, :labels, :authors]
    
    # These fields can't be overwritten by user's meta data when parsing raw_text.
    PROTECTED_FIELDS = [:_id, :parent_id, :level, :created_at, :updated_at, :default_slug, :content, :raw_text, :position, :grid_files]
    
    def children
      Page.where(:parent_id => self.id)
    end
    
    def parent
      Page.find(self.parent_id)
    end
    
    def content_in_html
      if self.content_is_markdown?
        Redcarpet.new(self.content, :smart).to_html
      else
        return nil
      end
    end
    
    def content_is_haml?
      if self[:template_engine] && self.template_engine.downcase == "haml"
        return true
      else
        return false
      end
    end
    
    def content_is_markdown?
      if !self[:template_engine] || self.template_engine == "markdown"
        return true
      else
        return false
      end
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
    
    def others(filename=nil)
      excluded_ids = []
      [:images, :stylesheets, :javascripts].each do |file_type|
        excluded_ids += self.send(file_type).map(&:_id)
      end
      Rails.logger.info { "---#{excluded_ids}" }
      self.grid_files.where(:_id.nin => excluded_ids)
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
        self.content = raw_text_array.last.strip
      else
        meta_data = self.raw_text.strip
        self.content = nil
      end
      meta_data = underscore_hash_keys(YAML.load(meta_data))
      meta_data.each do |key, value|
        unless ControlCenter::Page::PROTECTED_FIELDS.include?(key)
          if key == :publish_time
            self.parse_publish_time(value)
          else
            self[key] = value
          end
        end
      end
      # Set the field to nil if the value isn't present in meta data.
      (self.attributes.keys.map{ |k| k.to_sym } - PROTECTED_FIELDS).each do |field|
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
    
    def published?
      self.publish_time.present?
    end
    
    def previous(*args)
      options = args.extract_options!
      if options[:only_published]
        children = self.parent.children.published.asc(:position)
        first = self.first?(:only_published => true)
      else
        children = self.parent.children.asc(:position)
        first = self.first?
      end
      if first
        return false
      else
        children.each_with_index { |child, index| return children.to_a[index-1] if child.id == self.id }
      end
    end

    def next(*args)
      options = args.extract_options!
      if options[:only_published]
        children = self.parent.children.published.asc(:position)
        last = self.last?(:only_published => true)
      else
        children = self.parent.children.asc(:position)
        last = self.last?
      end
      if last
        return false
      else
        children.each_with_index { |child, index| return children.to_a[index+1] if child.id == self.id }
      end
    end
    
    def first?(*args)
      options = args.extract_options!
      if options[:only_published]
        children = self.parent.children.published.asc(:position)
      else
        children = self.parent.children.asc(:position)
      end
      if children.first
        if self.id == children.first.id
          return true
        else
          return false
        end
      else
        return false
      end
    end

    def last?(*args)
      options = args.extract_options!
      if options[:only_published]
        children = self.parent.children.published.asc(:position)
      else
        children = self.parent.children.asc(:position)
      end
      if children.last
        if self.id == children.last.id
          return true
        else
          return false
        end
      else
        return false
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
    
    def unset_unused_dynamic_fields
      target_fields = {}
      for field in self.attributes.keys
        if !PREDEFINED_FIELDS.include?(field.to_sym) && self[field.to_sym].nil?
          target_fields[field.to_s] = 1
        end
      end
      Page.collection.update({"_id" => self.id}, {"$unset" => target_fields})
    end
    
    def set_publish_month
      if self.publish_time
        self.publish_month = Time.zone.local(self.publish_time.year, self.publish_time.month)
      end
    end
  end
end
