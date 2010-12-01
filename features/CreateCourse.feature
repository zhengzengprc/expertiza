Feature: Create a Course
  Expertiza will allow an instructor to create a course.

  Scenario: Instructor can create a course
    Given "Dr Gehringer" logs into the system             # NB: Dr Gehringer is an instructor
      And will create a course named "CSC517"    
    Then the course named "CSC517" will exists
