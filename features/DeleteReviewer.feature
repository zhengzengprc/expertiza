Feature: Delete reviewer for an assignment
  Expertiza will allow an instructor or TA to delete
  a reviewer for an assignment for a team.

  Scenario: Instructor can delete a reviewer for an assignment
    Given "Gehringer":"gehringer" logs into the system
      And the assignment named "foo" will exist
      And user "mtreece" is a reviewer of "foo"
    When user deletes "mtreece" as a reviewer of "foo"
      Then user "mtreece" will not be a reviewer of "foo"

  Scenario: TA can delete a reviewer for an assignment
    Given "Titus":"titus" logs into the system
      And the assignment named "bar" will exist
      And user "mtreece" is a reviewer of "bar"
    When user deletes "mtreece" as a reviewer of "foo"
      Then user "mtreece" will not be a reviewer of "foo"
