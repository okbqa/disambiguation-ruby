require 'test_helper'

class ResourceTest < ActiveSupport::TestCase
  test "find" do
    question = "How many students does the Free University of Berlin have?"
    resource_verbalizations = ["Free University of Berlin"]
    
    assert Resource.find(question, resource_verbalizations)
  end
end