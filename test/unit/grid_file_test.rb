require "test_helper"

class GridFileTest < ActiveSupport::TestCase
  test "should store file in GridFS" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    assert_equal grid_file.read, File.read("#{Rails.root}/public/404.html")
  end

  test "should delete file from GridFS when page is deleted" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    grid_id = grid_file.grid_id.dup
    page.destroy
    grid = Mongo::Grid.new Mongoid.database
    assert_raise(Mongo::GridFileNotFound) { grid.get(grid_id).read }
  end

  test "should delete associated grid_file when page is deleted" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    page.destroy
  end

  test "should store correct original_filename" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    assert_equal grid_file.original_filename, "404.html"
  end

  test "should include id in filename" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    assert grid_file.filename.include?(grid_file.grid_id.to_s), "Filename does not include grid_id."
  end
end
