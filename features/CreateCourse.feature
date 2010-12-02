Feature: Create a Course
  Expertiza will allow an instructor to create a course.

  Scenario: Instructor can create a course
    Given "Instructor-test" logs into the system             # NB: test instructor
      And will create a course named "CSC517"    
    Then the course named "CSC517" will exists
