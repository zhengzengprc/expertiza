module WatirConfig

  @@consts = Hash.new
  
  ###########################################################  
  # SERVER SPECIFIC NEED TO CHANGE PER TEST 
  ###########################################################  
  @@consts["ADMIN_USERNAME"] = 'admin'
  @@consts["ADMIN_PASSWORD"] = 'admin'
  @@consts["ASSIGN_REVIEWERS_IMPORT_FILENAME"] = "C:\\cuke\\assignReviewers.csv"
  @@consts["ASSIGNMENT_LIST"] = '/tree_display/list'
  @@consts["ASSIGNMENT_TO_COURSE"] = '/assignment/associate_assignment_to_course/'
  @@consts["ASSIGNMENT_MENU_LIST"] = '/menu/manage/assignments'
  @@consts["COURSE_MENU_LIST"] = '/menu/manage/courses'
  @@consts["CREATE_TEAM_IMPORT_FILENAME"] = "Z:\\ruby\\InstantRails\\rails_apps\\project\\cuke\\importUsersToCourse.csv"
  @@consts["SERVER_URL"] = "http://vistawiles.raleigh.ibm.com:3000"
  ###########################################################  

  #test params for accept_team_invite
  @@consts["ACCEPT_TEAM_INVITE_USERS_NUMBER"] = 3
  @@consts["ACCEPT_TEAM_INVITE_USERNAME"] = 'cukeuser'
  
  #test params for accept team invite feature
  @@consts["ACCEPT_TEAM_INVITE_USER_LOGIN"] = 'cukeuser2'
  @@consts["ACCEPT_TEAM_INVITE_USER_PASSWORD"] = 'cukeuser2'
  @@consts["ACCEPT_TEAM_INVITE_ASSIGNMENT"] = 'cukeassignment'

  #test params for assigning an assignment to a course
  @@consts["ASSIGN_ASSIGNMENT_COURSE"] = 'democourse'
  @@consts["ASSIGN_ASSIGNMENT_NAME"] = 'demoassignment'
 
  #test params for assign reviewers
  @@consts["ASSIGN_REVIEWERS_COURSE"] = 'cukecourse'
  @@consts["ASSIGN_REVIEWERS_IMPORT_TEAMS"] = ['user1', 'user2', 'user3', 'user4']

  #test params for add_participant_to_assignment feature
  @@consts["ADD_PARTICIPANT_TO_ASSIGNMENT_ASSIGNMENTNAME"] = 'cukeassignment'

  #test params for create_team feature
  @@consts["CREATE_TEAM_ASSIGNMENT"] = 'cukeassignment'
  @@consts["CREATE_TEAM_TEAM_NAME"] = 'cukeuser1Team'
  @@consts["CREATE_TEAM_USERS"] = ['cukeuser2', 'cukeuser3', 'cukeuser4']
  @@consts["CREATE_TEAM_USER_LOGIN"] = 'cukeuser1'
  @@consts["CREATE_TEAM_USER_PASSWORD"] = 'cukeuser1'
  @@consts["CREATE_TEAM_COURSE"] = 'cukecourse'
  
  #test params for create_team_from_import feature
  @@consts["CREATE_TEAM_IMPORT_TEAMS"] = ['importedTeamName123', 'importedTeamName45']
    
  #test params for create_users feature
  @@consts["CREATE_USERS_NUMBER"] = 5
  @@consts["CREATE_USERS_USERNAME"] = 'cukeuser'
  
  #test params for signup for topic
  @@consts["SIGNUP_USER_LOGIN"] = 'cukeuser1'
  @@consts["SIGNUP_USER_PASSWORD"] = 'cukeuser1'
    
  #test params for submit metareview
  @@consts["SUBMIT_METAREVIEW_ASSIGNMENT"] = 'assignment6'
  @@consts["SUBMIT_METAREVIEW_LOGIN"] = 'user3'
  @@consts["SUBMIT_METAREVIEW_PASSWORD"] = 'user3'

  ###########################################################  
  #demo params
  @@consts["DEMO_ASSIGN_ASSIGNMENT_COURSE"] = 'democourse'
  @@consts["DEMO_ASSIGN_ASSIGNMENT_NAME"] = 'demoassignment'
  @@consts["DEMO_CREATE_USERS_NUMBER"] = 5
  @@consts["DEMO_CREATE_USERS_USERNAME"] = 'demouser'
  @@consts["DEMO_CREATE_TEAM_IMPORT_FILENAME"] = "Z:\\ruby\\InstantRails\\rails_apps\\project\\cuke\\importDemoUsersToCourse.csv"
  @@consts["DEMO_CREATE_TEAM_IMPORT_TEAMS"] = ['importedDemoTeamName123', 'importedDemoTeamName45']
  ###########################################################  
 
  def consts
    @@consts
  end
  
  #used to return values so we dont have to code them in the scenario definition
  def self.getValue key
    if(@@consts.has_key? key)
      return @@consts[key]
    else
      return key
    end
  end
end