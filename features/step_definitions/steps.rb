require 'firewatir'
require 'capybara/cucumber'

#$ff=FireWatir::Firefox.new

Given /^"([^"]*)":"([^"]*)" logs into the system/ do |user_name, user_pw|
  $ff.goto("http://localhost:3000")

  # if already logged in, log us out
  if($ff.button(:value, "Logout").exists?)
    $ff.button(:value, "Logout").click
  end

  $ff.text_field(:name,"login[name]").set(user_name)
  $ff.text_field(:name,"login[password]").set(user_pw)
  $ff.button(:value,"Login").click
end

Given /^user will create an assignment named "([^"]*)"$/ do |assignment_name|
  # make an arbitrary assignment object in the system
  # with non-important settings...

  # if doesn't have "Manage...", fail immediately
  if(!$ff.contains_text "Manage...")
    fail "I cannot find the \"Manage...\" link!"
  end
  $ff.link(:text, "Manage...").click
  $ff.link(:text, "Create Public Assignment").click
  
  $ff.text_field(:name,"assignment[name]").set(assignment_name)
  $ff.text_field(:name,"assignment[directory_path]").set("td")
  $ff.text_field(:name,"assignment[spec_location]").set("xyz")  

  $ff.select_list(:name,"assignment[wiki_type_id]").select("No")
  $ff.select_list(:name,"assignment[team_assignment]").select("Yes")
  $ff.select_list(:name,"assignment[staggered_deadline]").select("No")
 #$ff.text_field(:name,"assignment[codereview]").value = ("false")
 #$ff.text_field(:name,"assignment[team_assignment]").value = ("true")
 #$ff.text_field(:name,"assignment[staggered_deadline]").value = ("true")


  $ff.text_field(:name,"weights[selfassessment]").set("10")
  $ff.text_field(:name,"limits[selfassessment]").set("30")
 
  $ff.text_field(:name,"weights[review]").set("15")
  $ff.text_field(:name,"limits[review]").set("25")

  $ff.text_field(:name,"weights[metareview]").set("35")
  $ff.text_field(:name,"limits[metareview]").set("45")
 
  $ff.text_field(:name,"weights[feedback]").set("35")
  $ff.text_field(:name,"limits[feedback]").set("45")
 
  $ff.text_field(:name,"weights[supervisor]").set("35")
  $ff.text_field(:name,"limits[supervisor]").set("45")
 
  $ff.text_field(:name,"weights[reader]").set("35")
  $ff.text_field(:name,"limits[reader]").set("45")
 
  $ff.text_field(:name,"assignment[dynamic_reviewer_response_time_limit_hours]").set("48")
  $ff.text_field(:name,"submit_deadline[due_at]").set("2010-12-18 01:59:32")
  $ff.text_field(:name,"review_deadline[due_at]").set("2010-12-28 01:59:32")
  $ff.text_field(:name,"switch_deadline[due_at]").set("2011-01-03 01:59:32")

  $ff.select_list(:name,"submit_deadline[submission_allowed_id]").select("No")
  $ff.select_list(:name,"review_deadline[submission_allowed_id]").select("OK")
  $ff.select_list(:name,"reviewofreview_deadline[submission_allowed_id]").select("Late")
  $ff.select_list(:name,"switch_deadline[submission_allowed_id]").select("OK")


  $ff.select_list(:name,"submit_deadline[threshold]").select("16")
  $ff.button(:name, "save").click #hit create
  
end


Then /^the assignment named "([^"]*)" will exist$/ do |assignment_name|
  if(!$ff.contains_text "Manage...")
    fail "I cannot find the \"Manage...\" link!"
  end
  $ff.link(:text, "Manage...").click
  $ff.link(:name, '3_3Link').click
  assert($ff.contains_text assignment_name)
end


Given /^user "([^"]*)" is a participant of "([^"]*)"$/ do |arg1, arg2|
 
  if(!$ff.contains_text "Manage...")
    fail "I cannot find the \"Manage...\" link!"
  end
  
  $ff.link(:text, "Manage...").click
 
  $ff.link(:id, "3_3Link").fire_event("onClick")
 #Add participant 
  $ff.link(:text, "Add/remove participants").click
end

Given /^user "([^"]*)" is a reviewer of "([^"]*)" for "([^"]*)"/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Given /^user "([^"]*)" reviews "([^"]*)"/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^user deletes review of "([^"]*)" for "([^"]*)" by "([^"]*)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Then /^review of "([^"]*)" for "([^"]*)" by "([^"]*)" will not exist$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

#AddParticipant

#Given /^the assignment named "([^"]*)" will exist$/ do |assignment_name|
  #check if the assignment is created
 # $ff.link(:text, "Manage...").click
 # $ff.link(:name, '3_3Link').click
 # if(!$ff.contains_text assignment_name)
 #    Given user will create an assignment named  assignment_name
 # end
# end

When /^user adds "([^"]*)" to the assignment, "([^"]*)"/ do |user_name, assignment_name|
 #TODO
   assignment_xpath = "//td[]text()=#{assingment_name}"
   assignment_name_elem = element_by_xpath(assignment_xpath)
   assign_add_participant_link = element_by_xpath(following-sibling::assignment_xpath/li[4]/a/@href)
   $ff.link(:href, assign_add_participant_link).click
   
   #add username
   $ff.text_field(:name,"user[name]").set(user_name)  
   $ff.button(:value, "Add Participant").click
   
end

Then /^"([^"]*)" will be a participant of "([^"]*)"$/ do |arg1, arg2|
 #TODO
end

#adding a course

Given /^will create a course named "([^"]*)"$/ do |course_name|
   # make an arbitrary assignment object in the system
  # with non-important settings...

  # if doesn't have "Manage...", fail immediately
  if(!$ff.contains_text "Manage...")
    fail "I cannot find the \"Manage...\" link!"
  end
  $ff.link(:text, "Manage...").click
  $ff.link(:text, "Create Public Course").click
  
  $ff.text_field(:name,"course[name]").set(course_name)
  $ff.text_field(:name,"course[directory_path]").set("td")
  $ff.text_field(:name,"course[info]").set("test info")  

  $ff.button(:name, "commit").click #hit create
  
end

Then /^the course named "([^"]*)" will exists$/ do |course_name|

  if(!$ff.contains_text "Manage...")
    fail "I cannot find the \"Manage...\" link!"
  end
  $ff.link(:text, "Manage...").click
  $ff.link(:name, '2_2Link').click
  assert($ff.contains_text course_name)
end

Given /^user "([^"]*)" scored (\d+) on assignment "([^"]*)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

When /^user views scores for assignment "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^user "([^"]*)" will have a score of (\d+) for assignment "([^"]*)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Given /^user "([^"]*)" is a reviewer of "([^"]*)"$/ do |arg1, arg2|
  # !!! I don't think someone can be an arbitrary reviewer?
  pending # express the regexp above with the code you wish you had
end

When /^user deletes "([^"]*)" as a reviewer of "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^user "([^"]*)" will not be a reviewer of "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^the user deletes the assignment named "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^the assignment named "([^"]*)" will not exist$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^user has logged in$/ do
  assert($ff.button(:value, "Logout").exists?)
end

