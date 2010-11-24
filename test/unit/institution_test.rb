require File.dirname(__FILE__) + '/../test_helper'

class InstitutionTest < Test::Unit::TestCase
  fixtures :institutions
  
  def setup
    @institution = Institution.find(institutions(:institution0).id)
  end
  
  def test_create
    assert_kind_of Institution, @institution
    assert_equal institutions(:institution0).id, @institution.id
    assert_equal institutions(:institution0).name, @institution.name
  end
  
  def test_update
    assert_equal institutions(:institution0).name, @institution.name
    @institution.name = "Computer science"
    @institution.save
    @institution.reload
    assert_equal "Computer science", @institution.name
  end
  
  def test_destroy
    @institution.destroy
    assert_raise(ActiveRecord::RecordNotFound){ Institution.find(@institution.id) }
  end
  
end