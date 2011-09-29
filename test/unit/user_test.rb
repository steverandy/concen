require "test_helper"
require "minitest/spec"
require "minitest/autorun"

describe Concen::User do
  before do
    DatabaseCleaner.clean
  end

  it "can create user" do
    user = Fabricate "concen/user"
    user.id.wont_be_nil
  end

  it "has password_digest" do
    user = Fabricate "concen/user"
    user.password_digest.wont_be_nil
  end

  it "has auth_token" do
    user = Fabricate "concen/user"
    user.auth_token.wont_be_nil
  end

  it "has username" do
    user = Fabricate.build "concen/user", :username => nil
    lambda { user.save! }.must_raise(Mongoid::Errors::Validations)
    user.errors[:username].first.must_equal "can't be blank"
  end

  it "has email" do
    user = Fabricate.build "concen/user", :email => nil
    lambda { user.save! }.must_raise(Mongoid::Errors::Validations)
    user.errors[:email].first.must_equal "can't be blank"
  end

  it "has full_name" do
    user = Fabricate.build("concen/user", :full_name => nil)
    lambda { user.save! }.must_raise(Mongoid::Errors::Validations)
    user.errors[:full_name].first.must_equal "can't be blank"
  end

  it "must authenticate user" do
    password = {:password => "newpassword", :password_confirmation => "newpassword"}
    user = Fabricate "concen/user", password
    authenticated_user = user.authenticate("newpassword")
    authenticated_user.wont_equal false
    authenticated_user.must_be_instance_of Concen::User
  end
end
