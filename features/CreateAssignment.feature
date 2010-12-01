Feature: Create a new assignment
  Expertiza will allow an instructor or TA to create
  a new assignment for their course.

  Scenario: Instructor can create an assignment
    Given "Dr Gehringer" logs into the system             # NB: Dr Gehringer is an instructor
      And will create an assignment named "foo"
    Then the assignment named "foo" will exist

  Scenario: TA can create an assignment
    Given "Titus" logs into the system                    # NB: Titus is a TA
      And will create an assignment named "bar"
    Then the assignment named "bar" will exist
