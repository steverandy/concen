require "test_helper"

class PageTest < ActiveSupport::TestCase
  test "should create page" do
    page = Fabricate("control_center/page")
    assert_not_nil(page.id)
  end
  
  test "should create child page" do
    page = Fabricate("control_center/page")
    child_page = page.children.create(:title => "1984")
    assert_not_nil(child_page.id)
    assert_equal(page.id, child_page.parent.id)
  end
  
  test "should parse title from raw_text" do
    page = Fabricate("control_center/page", :title => nil, :raw_text => "Title: 1984")
    assert_equal(page.title, "1984")
  end
  
  test "should have default_slug" do
    page = Fabricate("control_center/page")
    assert_not_nil(page.default_slug)
    assert(page.default_slug.length > 0)
  end
  
  test "should not be created without title" do
    page = Fabricate.build("control_center/page", :title => nil)
    assert_raise(Mongoid::Errors::Validations) { page.save! }
		assert_equal(page.errors[:title].first, "can't be blank")
  end
end
