Feature: Delete an existing assignment
  Expertiza will allow an instructor or TA to delete
  an assignment for their course.

  Scenario: Instructor can delete an assignment
    Given "Dr Gehringer" logs into the system             # NB: Dr Gehringer is an instructor
      And the assignment named "foo" will exist
    When the user deletes the assignment named "foo"
      Then the assignment named "foo" will not exist

  Scenario: TA can delete an assignment
    Given "Titus" logs into the system                    # NB: Titus is a TA
      And the assignment named "bar" will exist
    When the user deletes the assignment named "bar"
      Then the assignment named "bar" will not exist

