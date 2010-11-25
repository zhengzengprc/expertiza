require 'test_helper'

class CodeReviewFileTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :code_review_files

  def test_empty_attributes
    crf = CodeReviewFile.new
    # Should not be valid, because name fiield has not been created.
    assert !crf.valid?
    assert crf.errors.invalid?(:name)
  end

  def test_get_participant_code_file
    #test if getParticipantCodeFiles returns the correct code file according to participant id
    crf = CodeReviewFile.getParticipantCodeFiles(code_review_files(:one).participantid)
    assert_equal(crf[0].contents, code_review_files(:one).contents)
    
  end
end
