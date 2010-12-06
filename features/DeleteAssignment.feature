Feature: Delete an existing assignment
  Expertiza will allow an instructor or TA to delete
  an assignment for their course.

  Scenario: Instructor can delete an assignment
    Given "Gehringer":"gehringer" logs into the system             
      And the assignment named "foo" will exist
    When the user deletes the assignment named "foo"
      Then the assignment named "foo" will not exist

 
