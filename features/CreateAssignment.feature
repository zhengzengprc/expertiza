Feature: Create a new assignment
  Expertiza will allow an instructor or TA to create
  a new assignment for their course.

  Scenario: Instructor can create an assignment
    Given "Gehringer":"gehringer" logs into the system             
      And will create an assignment named "foo"
    Then the assignment named "foo" will exist

  
