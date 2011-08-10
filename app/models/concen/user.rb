require "bcrypt"

module Concen
  class User
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in self.name.underscore.gsub("/", ".").pluralize

    field :full_name, :type => String
    field :username, :type => String
    field :email, :type => String
    field :password_digest, :type => String
    field :full_control, :type => Boolean, :default => false
    field :auth_token, :type => String
    field :password_reset_token, :type => String
    field :password_reset_sent_at, :type => Time
    field :invitation_token, :type => String
    field :invitation_sent_at, :type => Time

    attr_reader :password, :current_password
    attr_accessible :full_name, :username, :email, :password, :password_confirmation, :current_password

    validates_presence_of :username
    validates_presence_of :email
    validates_presence_of :full_name
    validates_presence_of :password_digest
    validates_uniqueness_of :username, :case_sensitive => false, :allow_blank => true
    validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true
    validates_length_of :username, :minimum => 3, :maximum => 30, :allow_blank => true
    validates_format_of :username, :with => /^[a-zA-Z0-9_]+$/, :allow_blank => true
    validates_confirmation_of :password
    validates_presence_of :password, :on => :create

    before_create { generate_token(:auth_token) }
    before_update :nulify_unused_token

    def authenticate(unencrypted_password)
      if BCrypt::Password.new(self.password_digest) == unencrypted_password
        self
      else
        false
      end
    end

    def password=(unencrypted_password)
      @password = unencrypted_password
      unless unencrypted_password.blank?
        self.password_digest = BCrypt::Password.create(unencrypted_password)
      end
    end

    def send_password_reset
      generate_token(:password_reset_token)
      self.password_reset_sent_at = Time.now
      save
      Rails.logger.info "--called"
      # Send email here.
    end

    def self.send_invitation(email)
      password = ActiveSupport::SecureRandom.hex(4)
      username = "user#{ActiveSupport::SecureRandom.hex(4)}"
      new_user = self.new(
        :full_name => username,
        :username => username,
        :email => email,
        :password => password,
        :password_confirmation => password
      )
      new_user.generate_token(:invitation_token)
      new_user.invitation_sent_at = Time.now
      new_user.save
      # Send email here.
    end

    def generate_token(field)
      self.write_attribute(field.to_sym, ActiveSupport::SecureRandom.urlsafe_base64)
    end

    def nulify_unused_token
      self.password_reset_token = nil
      self.password_reset_sent_at = nil
      self.invitation_token = nil
      self.invitation_sent_at = nil
    end
  end
end
