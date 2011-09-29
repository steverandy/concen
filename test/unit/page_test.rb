require "test_helper"
require "minitest/spec"
require "minitest/autorun"

describe Concen::Page do
  def setup
    DatabaseCleaner.clean
  end

  it "can create page" do
    page = Fabricate "concen/page"
    page.id.wont_be_nil
  end

  it "can create child page" do
    page = Fabricate "concen/page"
    child_page = page.children.create :title => "1984"
    child_page.id.wont_be_nil
    page.id.must_equal child_page.parent.id
  end

  it "must parse title from raw_text" do
    page = Fabricate "concen/page", :title => nil, :raw_text => "Title: Page Title"
    page.title.must_equal "Page Title"
  end

  it "won't be created without title" do
    page = Fabricate.build "concen/page", :title => nil
    lambda { page.save! }.must_raise(Mongoid::Errors::Validations)
    page.errors[:title].first.must_equal "can't be blank"
  end

  it "validates uniqueness of title" do
    parent_page = Fabricate "concen/page", :title => "Parent"
    child_page_1 = parent_page.children.create :title => "Child"
    child_page_2 = parent_page.children.build :title => "Child"
    lambda { child_page_2.save! }.must_raise(Mongoid::Errors::Validations)
    child_page_2.errors[:title].first.must_equal "is already taken"
  end

  it "must parse publish_time from raw_text" do
    raw_text = "Title: Page Title 2\n\nPublish Time: now"
    page = Fabricate "concen/page", :title => nil, :raw_text => raw_text
    page.publish_time.wont_be_nil
    page.raw_text.wont_equal raw_text
  end

  it "must parse multi content from raw_text and conver to html correctly" do
    raw_text = File.read "#{File.dirname(__FILE__)}/../support/raw_text/multi_content.txt"
    html = File.read("#{File.dirname(__FILE__)}/../support/raw_text/multi_content.html")
    page = Fabricate "concen/page", :title => nil, :raw_text => raw_text
    page.content.wont_be_nil
    page.content.keys.must_equal ["part_1", "part_2"]
    page.content_in_html("part_1").wont_be_nil
    page.content_in_html("part_2").wont_be_nil
    (page.content_in_html("part_1") + page.content_in_html("part_2")).must_equal html
  end

  it "must parse content with SmartyPants supported entities and convert to html correctly" do
    raw_text_smartypants = File.read "#{File.dirname(__FILE__)}/../support/raw_text/smartypants.txt"
    raw_text_smartypants_escape = File.read "#{File.dirname(__FILE__)}/../support/raw_text/smartypants_escape.txt"
    raw_text_smartypants.wont_be_nil
    raw_text_smartypants_escape.wont_be_nil

    page1 = Fabricate "concen/page", :title => nil, :raw_text => raw_text_smartypants
    page1.content_in_html.must_equal page1.content_in_html("main")
    page1.content_in_html.must_equal File.read("#{File.dirname(__FILE__)}/../support/raw_text/smartypants.html")

    page2 = Fabricate "concen/page", :title => nil, :raw_text => raw_text_smartypants_escape
    page2.content_in_html.must_equal page2.content_in_html("main")
    page2.content_in_html.must_equal File.read("#{File.dirname(__FILE__)}/../support/raw_text/smartypants_escape.html")
  end

  it "must parse content with code blocks and convert to html correctly" do
    raw_text_code_blocks = File.read "#{File.dirname(__FILE__)}/../support/raw_text/code_blocks.txt"
    raw_text_code_blocks.wont_be_nil

    page = Fabricate "concen/page", :title => nil, :raw_text => raw_text_code_blocks
    page.content_in_html.must_equal page.content_in_html("main")
    page.content_in_html.must_equal File.read("#{File.dirname(__FILE__)}/../support/raw_text/code_blocks.html")
  end

  it "must parse content with inline HTML and convert to html correctly" do
    raw_text_code_blocks = File.read "#{File.dirname(__FILE__)}/../support/raw_text/inline_html.txt"
    raw_text_code_blocks.wont_be_nil

    page = Fabricate "concen/page", :title => nil, :raw_text => raw_text_code_blocks
    page.content_in_html.must_equal page.content_in_html("main")
    page.content_in_html.must_equal File.read("#{File.dirname(__FILE__)}/../support/raw_text/inline_html.html")
  end

  it "has slug automatically generated" do
    page1 = Fabricate "concen/page", :title => "Something New"
    page1.slug.must_equal "something-new"

    page2 = Fabricate.build "concen/page", :title => nil
    page2.raw_text = File.read "#{File.dirname(__FILE__)}/../support/raw_text/title.txt"
    page2.save
    page2.slug.must_equal "something-new"
  end

  it "must be able to set slug from raw_text" do
    page = Fabricate.build "concen/page", :title => nil
    page.raw_text = File.read "#{File.dirname(__FILE__)}/../support/raw_text/slug.txt"
    page.save
    page.slug.must_equal "something-else"
  end

  it "has authors" do
    page = Fabricate.build "concen/page", :authors => ["user1", "user2", "user3"]
    page.authors.count.must_equal 3
  end

  it "must get correct author_as_user" do
    user = Fabricate "concen/user"
    page = Fabricate.build "concen/page", :authors => [user.username, "user2"]
    page.authors.count.must_equal 2
    page.authors_as_user.count.must_equal 1
    page.authors_as_user.must_include user.reload
  end

  it "must get the correct slug" do
    page = Fabricate "concen/page", :title => "New Title"
    page.slug.must_equal "new-title"
    page.write_attribute :slug, "new-slug"
    page.save
    page.slug.must_equal "new-slug"
  end

  it "must set/reset position correctly" do
    page = Fabricate "concen/page"
    child_page_1 = page.children.create :title => "Position 1"
    child_page_1.position.must_equal 1

    child_page_2 = page.children.create :title => "Position 2"
    child_page_2.position.must_equal 2

    child_page_3 = page.children.create :title => "Position 3"
    child_page_3.position.must_equal 3

    child_page_2.destroy
    child_page_3.reload.position.must_equal 2
  end

  it "must have ancestor_slugs" do
    page_1 = Fabricate "concen/page", :title => "A"

    page_2 = page_1.children.create :title => "B"
    page_2.ancestor_slugs.must_equal ["a"]

    page_3 = page_2.children.create :title => "C"
    page_3.ancestor_slugs.must_equal ["a", "b"]
  end

  it "must have level" do
    page_1 = Fabricate "concen/page", :title => "A"
    page_1.level.must_equal 0

    page_2 = page_1.children.create :title => "B"
    page_2.level.must_equal 1

    page_3 = page_2.children.create :title => "C"
    page_3.level.must_equal 2
  end
end
