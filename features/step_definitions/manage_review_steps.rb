#Test if the summitted teamate review successful
Then /^I should see the details of submitted teammate review$/ do
  should have_content "Teammate Review"
end

#Test if the summitted review successful
Then /^I should see the details of submitted review$/ do
  should have_content "Additional Comment"
end