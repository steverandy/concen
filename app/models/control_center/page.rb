module ControlCenter
  class Page
    include Mongoid::Document
    include Mongoid::Timestamps
    
    embeds_many :files

    field :parent_id, :type => BSON::ObjectId
    field :level, :type => Integer
    field :title, :type => String
    field :description, :type => String
    field :slug, :type => String
    field :content, :type => String
    field :position, :type => Integer
    field :publish_time, :type => Time
    
    validates_presence_of :title
    validates_presence_of :slug
    validates_uniqueness_of :title, :scope => [:parent_id, :level], :case_sensitive => false
    validates_uniqueness_of :slug, :scope => [:parent_id, :level], :case_sensitive => false
    
    before_validation :set_slug
    before_create :set_position
    before_destroy :destroy_children
    after_destroy :reset_position
    
    scope :with_position, where(:position.exists => true)
    
    protected
    
    def set_slug
      self.slug = self.title.parameterize if self.title
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
  end
end
