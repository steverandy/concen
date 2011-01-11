module ControlCenter
  class Admin
    include Mongoid::Document
    include Mongoid::Timestamps
           
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable,
           :authentication_keys => [:login]
           
    Devise.scoped_views = true
  
    field :username, :type => String
    field :full_name, :type => String
    field :time_zone, :type => String, :default => "UTC"
    field :past_months_statistics_follow_timezone, :type => Boolean
    
    index :username

    attr_accessible :username, :full_name, :email, :password, :password_confirmation, :time_zone
    attr_accessor :login
    
    validates_presence_of :username
    validates_uniqueness_of :username, :case_sensitive => false    
    validates_length_of :username, :minimum => 3
    validates_length_of :username, :maximum => 30
    validates_format_of :username, :with => /^[a-zA-Z0-9_]+$/
    validates_uniqueness_of :email, :case_sensitive => false
    validates_presence_of :full_name
    
    # Set username to be case insensitive.
    def self.find_for_authentication(conditions)
      conditions[:username].downcase!
      super
    end
    
    protected

    def self.find_for_database_authentication(conditions)
      value = conditions[authentication_keys.first].downcase
      self.any_of({ :username => value }, { :email => value }).first
    end
  end
end