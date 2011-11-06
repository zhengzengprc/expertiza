When /^I invite another student to join my team$/ do
  #Set default test value to false
  invite_flag = false

  #If exists button 'create team' then create it with team name 'test_team'
  if(!find_button("Create Team").nil?)
    fill_in 'team_name', :with => 'test_team'
    click_button 'Create Team'
  end

  #Inive another guy like 'admin' to your team
   if(!find_button("Invite").nil?)
    fill_in 'user_name', :with => 'admin'
    click_button 'Invite'
    invite_flag = true
   end

    invite_flag.should eql(true)
end

#check if the invitation successful
Then /^I should see that student in my sent invitations list$/ do
    should have_content('admin')
end

#check if current page contains other guy invitation
Given /^another student has invited me to their team$/ do
  if(!find_link("Accept").nil? && !find_link("Decline").nil?)
    assert true
  else
    assert false
  end
end

#Check if it exists pending invitation
Then /^I should see that I have an invite pending$/ do
  if(!find_link("Accept").nil? && !find_link("Decline").nil?)
    assert true
  else
    assert false
  end
end

# Accept the invitation
When /^I accept the invitation$/ do
  should have_link "Accept"
  click_link "Accept"
end

# Check if another guys in the team
Then /^I should see the person I invited on my team$/ do
  should have_content('admin')
end
