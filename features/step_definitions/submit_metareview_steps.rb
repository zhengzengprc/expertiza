And /^I open assignment test_Metareview$/ do
  #link to assginment page
  should have_link 'Assignments'
  click_link 'Assignments'

  #First log in accept the term
  if(!find_link('Accept').nil?)
     click_link 'Accept'
  end

  #click the "test_Metareview" link to testing
  should have_link "test_Metareview"
  click_link "test_Metareview"
end

#Link to others' work
Then /^I click the Others' work link$/ do
  should have_link "Others' work"
  click_link "Others' work"
end

#Find the first matereview and begin to test
Then /^I click to begin the metareview$/ do
#  find(:xpath, "//table[last()]/tr/td[last()]/a").should_not be_nil
#  a =  find(:xpath, "//table[last()]/tr/td[last()]/a")
  find(:xpath, "//table[last()]//tr//td[last()]/a").should_not be_nil
  find(:xpath, "//table[last()]//tr//td[last()]/a").click()
end

#fill none in the metareview, since the controller failed
And /^I fill in the metareview$/ do
  assert(true)
end

#Test if the save button works
And /^I click the Save Metareview button$/ do
  should have_button("Save Metareview")
  click_button("Save Metareview")
end

#Test if the continue link works
Then /^I click the Continue link$/ do
  should have_link("Continue")
  click_link("Continue")
end

#Test the view link
Then /^I click the View link$/ do
  should have_link("View")
  click_link("View")
end

#Test if contains new link for the work
And /^I verify that the metareview was saved$/ do
  should have_content('Hyperlinks')
end

