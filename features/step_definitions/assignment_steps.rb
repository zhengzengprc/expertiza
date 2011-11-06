Given /^I am participating on a team assignment$/ do
  #Find the "Assignments" link
  should have_link "Assignments"
  click_link 'Assignments'

  #If log in the first should accept the term to continue the test
  if(!find_link('Accept').nil?)
     click_link 'Accept'
  end

  #Find "test_team_invites" assignment and run the test
  should have_link "test_team_invites"
  click_link  "test_team_invites"
  should have_link "Your team"
  click_link "Your team"

end
