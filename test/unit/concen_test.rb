require "test_helper"

class ConcenTest < ActiveSupport::TestCase  
  def setup
    DatabaseCleaner.clean
  end
  
  test "must be a Module" do
    assert_kind_of Module, Concen
  end
end
