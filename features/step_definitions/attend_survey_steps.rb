#Find the assignment link
And /^I move to the "([^"]*)" page$/ do |assignment|
  should have_link assignment
  click_link assignment
end

And /^I click the "([^"]*)" link$/ do |task|
#First log in accept the term to continue
  if(!find_link('Accept').nil?)
    click_link 'Accept'
  end
#Find the task link
  should have_link task
  click_link task
end

#Test if the survey link works
And /^I click the "([^"]*)" link to the survey page$/ do |survey|
  should have_link survey
  click_link survey
end

#Fill in the email with 'test@gamil.com'
And /^I fill in my email address$/ do
  should have_button "Continue"
  fill_in 'email', :with => 'test@gamil.com'
end

#Check if the button works
And /^I click the "([^"]*)" button$/ do |button|
  should have_button button
  click_button button
end

#Test if it is successful redirect to the new link
Then /^I should have attended the survey$/ do
  should have_content('Welcome to Expertiza')
end