require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should create user" do
    user = Fabricate "concen/user"
    assert_not_nil user.id
  end

  test "shoud have password_digest" do
    user = Fabricate "concen/user"
    assert_not_nil user.password_digest
  end

  test "shoud have auth_token" do
    user = Fabricate "concen/user"
    assert_not_nil user.auth_token
  end

  test "should have username" do
    user = Fabricate.build "concen/user", :username => nil
    assert_raise(Mongoid::Errors::Validations) { user.save! }
    assert_equal user.errors[:username].first, "can't be blank"
  end

  test "should have email" do
    user = Fabricate.build "concen/user", :email => nil
    assert_raise(Mongoid::Errors::Validations) { user.save! }
    assert_equal user.errors[:email].first, "can't be blank"
  end

  test "should have full_name" do
    user = Fabricate.build("concen/user", :full_name => nil)
    assert_raise(Mongoid::Errors::Validations) { user.save! }
    assert_equal user.errors[:full_name].first, "can't be blank"
  end

  test "should authenticate user" do
    password = {:password => "newpassword", :password_confirmation => "newpassword"}
    user = Fabricate "concen/user", password
    assert user.authenticate("newpassword"), "Cannot authenticate user."
  end
end
