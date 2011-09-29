require "test_helper"
require "minitest/spec"
require "minitest/autorun"

describe Concen do
  before do
    DatabaseCleaner.clean
  end

  it "must be a Module" do
    Concen.must_be_kind_of Module
  end
end
