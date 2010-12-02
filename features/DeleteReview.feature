Feature: Delete review for an assignment
  Expertiza will allow an instructor or TA to delete
  a review for an assignment for a team.

  Scenario: Instructor can delete a review for an assignment
    Given "Dr Gehringer" logs into the system                         # NB: Dr Gehringer is an instructor
      And the assignment named "foo" will exist
      And user "sjain2" is a participant of "foo"
      And user "mtreece" is a reviewer of "foo" for "sjain2"          # NB: mtreece is a student, reviewer
      And user "mtreece" reviews "sjain2"                             # NB: arbitrary review for testing
    When user deletes review of "foo" for "sjain2" by "mtreece"
      Then review of "foo" for "sjain2" by "mtreece" will not exist

  Scenario: TA can delete a review for an assignment
    Given "Titus" logs into the system                                # NB: Titus is a TA
      And the assignment named "bar" will exist
      And user "sjain2" is a participant of "bar"
      And user "mtreece" is a reviewer of "bar" for "sjain2"          # NB: mtreece is a student, reviewer
      And user "mtreece" reviews "sjain2"                             # NB: arbitrary review for testing
    When user deletes review of "bar" for "sjain2" by "mtreece"
      Then review of "bar" for "sjain2" by "mtreece" will not exist
