require "test_helper"

class GridFileTest < ActiveSupport::TestCase  
  def setup
    DatabaseCleaner.clean
  end
  
  test "can store file in GridFS" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    assert_equal File.read("#{Rails.root}/public/404.html"), grid_file.read
  end

  test "must delete file from GridFS when page is deleted" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    grid_id = grid_file.grid_id.dup
    page.destroy
    grid = Mongo::Grid.new Mongoid.database
    assert_raise(Mongo::GridFileNotFound) { grid.get(grid_id).read }
  end

  test "must delete associated grid_file when page is deleted" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    refute_nil page.grid_files.where(:_id => grid_file.id).first
    page.destroy
    assert_nil page.grid_files.where(:_id => grid_file.id).first
  end
  
  test "must store correct original_filename" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    assert_equal "404.html", grid_file.original_filename
  end
  
  test "must include id in filename" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    assert grid_file.filename.include?(grid_file.grid_id.to_s)
  end
end
