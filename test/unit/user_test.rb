require "test_helper"

class UserTest < ActiveSupport::TestCase  
  def setup
    DatabaseCleaner.clean
  end
  
  test "can create user" do
    user = Fabricate "concen/user"
    assert_not_nil user.id
  end

  test "has password_digest" do
    user = Fabricate "concen/user"
    assert_not_nil user.password_digest
  end

  test "has auth_token" do
    user = Fabricate "concen/user"
    assert_not_nil user.auth_token
  end

  test "has username" do
    user = Fabricate.build "concen/user", :username => nil
    assert_raise(Mongoid::Errors::Validations) { user.save! }    
    assert_equal "can't be blank", user.errors[:username].first
  end
  
  test "has email" do
    user = Fabricate.build "concen/user", :email => nil
    assert_raise(Mongoid::Errors::Validations) { user.save! }
    assert_equal "can't be blank", user.errors[:email].first
  end
  
  test "has full_name" do
    user = Fabricate.build("concen/user", :full_name => nil)
    assert_raise(Mongoid::Errors::Validations) { user.save! }
    assert_equal "can't be blank", user.errors[:full_name].first
  end
  
  test "must authenticate user" do
    password = {:password => "newpassword", :password_confirmation => "newpassword"}
    user = Fabricate "concen/user", password
    authenticated_user = user.authenticate("newpassword")
    refute_equal false, authenticated_user
    assert_instance_of Concen::User, authenticated_user
  end
end
