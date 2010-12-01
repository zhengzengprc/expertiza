Feature: Add participants to an assignment
  Expertiza will allow an instructor or TA to add
  participants to an assignment

  Scenario: Instructor can add a participant to an assignment
    Given "Dr Gehringer" logs into the system                  # NB: Dr Gehringer is an instructor
      And the assignment named "foo" will exist
    When user adds "mtreece" to the assignment, "foo"          # NB: mtreece is a student
      Then "mtreece" will be a participant of "foo"

  Scenario: TA can add a participant to an assignment
    Given "Titus" logs into the system                         # NB: Titus is a TA
      And the assignment named "bar" will exist
    When user adds "mtreece" to the assignment, "bar"          # NB: mtreece is a student
      Then "mtreece" will be a participant of "bar"
