require "test_helper"
require "minitest/spec"
require "minitest/autorun"

describe Concen::GridFile do
  it "can store file in GridFS" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    grid_file.read.must_equal File.read("#{Rails.root}/public/404.html")
  end

  it "must delete file from GridFS when page is deleted" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    grid_id = grid_file.grid_id.dup
    page.destroy
    grid = Mongo::Grid.new Mongoid.database
    lambda { grid.get(grid_id).read }.must_raise(Mongo::GridFileNotFound)
  end

  it "must delete associated grid_file when page is deleted" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    page.destroy
  end

  it "must store correct original_filename" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    grid_file.original_filename.must_equal "404.html"
  end

  it "must include id in filename" do
    page = Fabricate "concen/page"
    grid_file = page.grid_files.build
    grid_file.store File.read("#{Rails.root}/public/404.html"), "404.html"
    grid_file.filename.must_include grid_file.grid_id.to_s
  end
end
