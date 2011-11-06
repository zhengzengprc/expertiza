#Fill in new team name
And /^I fill in the new team name "([^"]*)"$/ do |team_name|
  should have_button "Save"
  fill_in 'team_name', :with => team_name
end

#New team name reflects in the page
Then /^I should see the team name has changed to "([^"]*)"$/ do |team_name|
  should have_content(team_name)
end