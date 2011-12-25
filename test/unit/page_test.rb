require "test_helper"

class ConcenTest < ActiveSupport::TestCase  
  def setup
    DatabaseCleaner.clean
  end
  
  test "can create page" do
    page = Fabricate "concen/page"
    refute_nil page.id
  end

  test "can create child page" do
    page = Fabricate "concen/page"
    child_page = page.children.create :title => "1984"
    refute_nil child_page.id
    assert_equal child_page.parent.id, page.id
  end

  test "must parse title from raw_text" do
    page = Fabricate "concen/page", :title => nil, :raw_text => "Title: Page Title"
    assert_equal "Page Title", page.title
  end

  test "must get default title when none is present" do
    page = Fabricate "concen/page", :title => nil
    assert_equal "Untitled 1", page.title
  end

  test "validates uniqueness of title" do
    parent_page = Fabricate "concen/page", :title => "Parent"
    child_page_1 = parent_page.children.create :title => "Child"
    child_page_2 = parent_page.children.build :title => "Child"
    assert_raise(Mongoid::Errors::Validations) { child_page_2.save! }
    assert_equal "is already taken", child_page_2.errors[:title].first
  end

  test "must parse publish_time from raw_text" do
    raw_text = "Title: Page Title 2\n\nPublish Time: now"
    page = Fabricate "concen/page", :title => nil, :raw_text => raw_text
    refute_nil page.publish_time
    refute_equal raw_text, page.raw_text
    assert page.raw_text.include?(Time.now.utc.strftime("%Y-%m-%d"))
  end

  test "must parse multi content from raw_text and conver to html correctly" do
    raw_text = File.read "#{File.dirname(__FILE__)}/../support/raw_text/multi_content.txt"
    html = File.read("#{File.dirname(__FILE__)}/../support/raw_text/multi_content.html")
    page = Fabricate "concen/page", :title => nil, :raw_text => raw_text
    refute_nil page.content
    assert_equal ["part_1", "part_2"], page.content.keys
    refute_nil page.content_in_html("part_1")
    refute_nil page.content_in_html("part_2")
    assert_equal html, (page.content_in_html("part_1") + page.content_in_html("part_2"))
  end

  test "must parse content with SmartyPants supported entities and convert to html correctly" do
    raw_text_smartypants = File.read "#{File.dirname(__FILE__)}/../support/raw_text/smartypants.txt"
    raw_text_smartypants_escape = File.read "#{File.dirname(__FILE__)}/../support/raw_text/smartypants_escape.txt"
    refute_nil raw_text_smartypants
    refute_nil raw_text_smartypants_escape

    page1 = Fabricate "concen/page", :title => nil, :raw_text => raw_text_smartypants
    assert_equal page1.content_in_html("main"), page1.content_in_html
    assert_equal File.read("#{File.dirname(__FILE__)}/../support/raw_text/smartypants.html"), page1.content_in_html

    page2 = Fabricate "concen/page", :title => nil, :raw_text => raw_text_smartypants_escape
    assert_equal page2.content_in_html("main"), page2.content_in_html
    assert_equal File.read("#{File.dirname(__FILE__)}/../support/raw_text/smartypants_escape.html"), page2.content_in_html
  end

  test "must parse content with code blocks and convert to html correctly" do
    raw_text_code_blocks = File.read "#{File.dirname(__FILE__)}/../support/raw_text/code_blocks.txt"
    refute_nil raw_text_code_blocks

    page = Fabricate "concen/page", :title => nil, :raw_text => raw_text_code_blocks
    assert_equal page.content_in_html("main"), page.content_in_html
    assert_equal File.read("#{File.dirname(__FILE__)}/../support/raw_text/code_blocks.html"), page.content_in_html
  end

  test "must parse content with inline HTML and convert to html correctly" do
    raw_text_code_blocks = File.read "#{File.dirname(__FILE__)}/../support/raw_text/inline_html.txt"
    refute_nil raw_text_code_blocks

    page = Fabricate "concen/page", :title => nil, :raw_text => raw_text_code_blocks
    assert_equal page.content_in_html("main"), page.content_in_html
    assert_equal File.read("#{File.dirname(__FILE__)}/../support/raw_text/inline_html.html"), page.content_in_html
  end

  test "has slug automatically generated" do
    page1 = Fabricate "concen/page", :title => "Something New"
    assert_equal "something-new", page1.slug

    page2 = Fabricate.build "concen/page", :title => nil
    page2.raw_text = File.read "#{File.dirname(__FILE__)}/../support/raw_text/title.txt"
    page2.save
    assert_equal "something-new", page2.slug
  end

  test "must be able to set slug from raw_text" do
    page = Fabricate.build "concen/page", :title => nil
    page.raw_text = File.read "#{File.dirname(__FILE__)}/../support/raw_text/slug.txt"
    page.save
    assert_equal "something-else", page.slug
  end

  test "has authors" do
    page = Fabricate.build "concen/page", :authors => ["user1", "user2", "user3"]
    assert_equal 3, page.authors.count
  end

  test "must get correct author_as_user" do
    user = Fabricate "concen/user"
    page = Fabricate.build "concen/page", :authors => [user.username, "user2"]
    assert_equal 2, page.authors.count
    assert_equal 1, page.authors_as_user.count
    assert page.authors_as_user.include?(user.reload)
  end

  test "must get the correct slug" do
    page = Fabricate "concen/page", :title => "New Title"
    assert_equal "new-title", page.slug
    page.write_attribute :slug, "new-slug"
    page.save
    assert_equal "new-slug", page.slug
  end

  test "must set/reset position correctly" do
    page = Fabricate "concen/page"
    child_page_1 = page.children.create :title => "Position 1"
    assert_equal 1, child_page_1.position

    child_page_2 = page.children.create :title => "Position 2"
    assert_equal 2, child_page_2.position

    child_page_3 = page.children.create :title => "Position 3"
    assert_equal 3, child_page_3.position

    child_page_2.destroy
    assert_equal 2, child_page_3.reload.position
  end

  test "must have ancestor_slugs" do
    page_1 = Fabricate "concen/page", :title => "A"

    page_2 = page_1.children.create :title => "B"
    assert_equal ["a"], page_2.ancestor_slugs

    page_3 = page_2.children.create :title => "C"
    assert_equal ["a", "b"], page_3.ancestor_slugs
  end

  test "must have level" do
    page_1 = Fabricate "concen/page", :title => "A"
    assert_equal 0, page_1.level

    page_2 = page_1.children.create :title => "B"
    assert_equal 1, page_2.level

    page_3 = page_2.children.create :title => "C"
    assert_equal 2, page_3.level
  end
end
