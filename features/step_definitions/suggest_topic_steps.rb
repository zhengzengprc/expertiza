#suggest the new topic with title 'test' and content 'test'
And /^I fill out the new suggestion form$/ do
    fill_in 'suggestion_title', :with => 'test'
  fill_in 'suggestion_description', :with => 'test'
end