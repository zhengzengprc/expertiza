#Fill in the handle with 'test'
And /^I fill in my new handle$/ do
  should have_button "Save"
  fill_in 'participant_handle', :with => 'test'
end

# test if the change successful
Then /^I should have changed my handle for current assignment$/ do
  should have_content('Click the activity you wish to perform on the assignment titled')
end