Feature: Delete reviewer for an assignment
  Expertiza will allow an instructor or TA to delete
  a reviewer for an assignment for a team.

  Scenario: Instructor can delete a reviewer for an assignment
    Given "Dr Gehringer" logs into the system             # NB: Dr Gehringer is an instructor
      And the assignment named "foo" will exist
      And user "mtreece" is a reviewer of "foo"           # NB: mtreece is a student
    When user deletes "mtreece" as a reviewer of "foo"
      Then user "mtreece" will not be a reviewer of "foo"

  Scenario: TA can delete a reviewer for an assignment
    Given "Titus" logs into the system                    # NB: Titus is a TA
      And the assignment named "bar" will exist
      And user "mtreece" is a reviewer of "bar"           # NB: mtreece is a student
    When user deletes "mtreece" as a reviewer of "foo"
      Then user "mtreece" will not be a reviewer of "foo"
