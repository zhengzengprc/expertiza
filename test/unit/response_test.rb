require File.dirname(__FILE__) + '/../test_helper'

class ResponseTest < Test::Unit::TestCase
  fixtures :responses, :response_maps

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_new_response
    r = Response.new
    r.map_id = response_maps(:response_maps0).id
    assert r.save
  end
end
