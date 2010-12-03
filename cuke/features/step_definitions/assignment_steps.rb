################################################################
# These methods are used to manipulate assignments in expertiza
################################################################

##########################################################
And /^I open assignment (.*)$/ do |assignmentname|
  #ensure we are on the assignments page
  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}/student_task/list")
  @browser.wait
  @logger.info("assignment_steps.rb: assume there is an assignment created already")
  if (@browser.link(:text, WatirConfig.getValue(assignmentname)).exists?)
    @browser.link(:text, WatirConfig.getValue(assignmentname)).click
    @browser.wait
    @logger.info("assignment_steps.rb: assignment (#{WatirConfig.getValue(assignmentname)} clicked")
  else
    @logger.error("assignment_steps.rb: assignment (#{WatirConfig.getValue(assignmentname)} does not exist)")
    exit
  end
end

Then /^I click the "(.*)" link$/ do |linktext|
  @logger.info("assignment_steps.rb: Clicking on the link for #{linktext}")
  if (@browser.link(:text, linktext).exists?)
    @browser.link(:text, linktext).click
    @browser.wait
    @logger.info("assignment_steps.rb: assignment (#{linktext} clicked")
  else
    @logger.error("assignment_steps.rb: assignment (#{linktext} does not exist)")
    exit
  end
end

And /^I enter the hyperlink (.*) for my work$/ do |hyperlink|
  #update the team name
  @logger.info("assignment_steps.rb: Enter Hyperlink for submit work")
  @browser.text_field(:name, "submission").set(hyperlink)
end


And /^I click the Upload Link button$/ do
  @browser.button(:name, "upload_link").click
  @browser.wait
end

Then /^I should see that the link (.*) is present on the page$/ do |newlink|
  if (@browser.html.include?("#{newlink}"))
    @logger.info("assignment_steps.rb: Team (#{newlink}) created")
  else
    @logger.error("assignment_steps.rb: Team (#{newlink}) not created")
    exit  
  end
end

Then /^I click to Add Participants for assignment (.*)$/ do |assignmentnameLookup|
  assignmentname = WatirConfig.getValue(assignmentnameLookup)

  #find the table of assignmnts
  table = @browser.table(:id, "theTable")
  #see howmany rows there are, exclude the header
  count = table.row_count_excluding_nested_tables
  @logger.info("assignmnt_steps.rb: number of rows=#{count} ")
  #traverse the rows
  assignmentId = 0
  2.upto(count) do |i| 
    row_values = table.row_values(i)
	@logger.info("assignment_steps.rb: row_values = #{row_values}")
	@logger.info("assignment_steps.rb: row_values[2] = #{row_values[2]}")

    if (row_values[2] =~ /#{assignmentname}/)
      assignmentInfo = row_values[2]
	  split_row_values = assignmentInfo.split(' ')
	  assignmentId = split_row_values[1]
      @logger.info("assignment_steps.rb: assignmentId = #{assignmentId}")
    end
  end
  
  
  @logger.info("assignment_steps.rb: Click on link to add participants") 
  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}/participants/list/#{assignmentId}?model=Assignment")
  @browser.wait
end

##########################################################
And /^make sure the reviewers (.*) are created$/ do |reviewerLookup|
  @logger.info("assignment_steps.rb: make sure the reviewers are created")
  teams = WatirConfig.getValue(reviewerLookup)
    
  for i in 1..teams.size do
    if (@browser.html.include?("#{teams[i-1]}"))
      @logger.info("assignment_steps.rb: reviewer (#{teams[i-1]}) was imported to course")
    else
      @logger.error("assignment_steps.rb: reviewer (#{teams[i-1]}) was not imported to course")
	  exit
    end
  end  
end

And /^I fill in the metareview$/ do
  @browser.text_field(:id, "responses_0_comments").set("metareviewtext")
  @browser.text_field(:id, "responses_1_comments").set("metareviewtext")
  @browser.text_field(:id, "responses_2_comments").set("metareviewtext")
  @browser.text_field(:id, "responses_3_comments").set("metareviewtext")
  @browser.text_field(:id, "responses_4_comments").set("metareviewtext")
end

And /^I verify that the metareview was saved$/ do
  if (@browser.html.include?("metareviewtext"))
    @logger.info("assignment_steps.rb: Metareview created")
  else
    @logger.error("assignment_steps.rb: Metareview not created")
    exit  
  end
end

Then /^I click to begin the metareview$/ do
  @logger.info("assignment_steps.rb: Clicking on the link for a metareview")
  if (@browser.link(:text, "Begin").exists?)
    @browser.link(:text, "Begin").click
    @browser.wait
  elsif(@browser.link(:text, "Edit").exists?)
    @browser.link(:text, "Edit").click
    @browser.wait
  else
    @logger.error("assignment_steps.rb: Metareview link does not exist)")
    exit
  end
end

##########################################################
When /^I find the popup for (.*) I click on assign reviewers$/ do |assignmentnamelookup|
  assignmentname = WatirConfig.getValue(assignmentnamelookup)
  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}/menu/manage/assignments")
  @browser.wait
  @logger.info("assignment_steps.rb: assume there is an assignment created already")
  if (@browser.html.include?(assignmentname))
    @logger.info("assignment_steps.rb: assignment #{assignmentname} found")
  else
    @logger.error("assignment_steps.rb: assignment (#{assignmentname} does not exist)")
    exit
  end
  
  #find the table of assignmnts
  table = @browser.table(:id, "theTable")
  #see howmany rows there are, exclude the header
  count = table.row_count_excluding_nested_tables
  @logger.info("assignmnt_steps.rb: number of rows=#{count} ")
  #traverse the rows
  assignmentId = 0
  2.upto(count) do |i| 
    row_values = table.row_values(i)
	@logger.info("assignment_steps.rb: row_values = #{row_values}")
	@logger.info("assignment_steps.rb: row_values[2] = #{row_values[2]}")

    if (row_values[2] =~ /#{assignmentname}/)
      assignmentInfo = row_values[2]
	  split_row_values = assignmentInfo.split(' ')
	  assignmentId = split_row_values[1]
      @logger.info("assignment_steps.rb: assignmentId = #{assignmentId}")
    end
  end
  
  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}/review_mapping/list_mappings/#{@assignmentId}")
  @browser.wait
end

And /^I click to delete the reviewer and verify they are gone$/ do
  @logger.info("assignment_steps.rb: Click on link to delete a reviewer")
  @browser.link(:url,/delete_reviewer/).click
  @browser.wait
  
  if (@browser.html.include?("add metareviewer"))
    @logger.info("assignment_steps.rb: reviewer was deleted")
  else
    @logger.error("assignment_steps.rb: reviewer was not deleted")
    exit
  end
end

Then /^I look for assignment (.*) and add it to course (.*)$/ do |assignmentnameLookup, coursenameLookup|
  assignmentname = WatirConfig.getValue(assignmentnameLookup)
  coursename = WatirConfig.getValue(coursenameLookup)
  
  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}/menu/manage/assignments")
  @logger.info("assignment_steps.rb: assume there is a assignment created already")
  if (@browser.html.include?(assignmentname))
    @logger.info("assignment_steps.rb: assignment #{assignmentname} found")
  else
    @logger.error("assignment_steps.rb: assignment (#{assignmentname} does not exist)")
    exit
  end
  
  #find the table of assignmnts
  table = @browser.table(:id, "theTable")
  #see howmany rows there are, exclude the header
  count = table.row_count_excluding_nested_tables
  @logger.info("assignmnt_steps.rb: number of rows=#{count} ")
  #traverse the rows
  assignmentId = 0
  2.upto(count) do |i| 
    row_values = table.row_values(i)
	@logger.info("assignment_steps.rb: row_values = #{row_values}")
	@logger.info("assignment_steps.rb: row_values[2] = #{row_values[2]}")

    if (row_values[2] =~ /#{assignmentname}/)
      assignmentInfo = row_values[2]
	  split_row_values = assignmentInfo.split(' ')
	  assignmentId = split_row_values[1]
      @logger.info("assignment_steps.rb: assignmentId = #{assignmentId}")
    end
  end
  
  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}#{WatirConfig.getValue("COURSE_MENU_LIST")}")
  #find the table of courses
  table = @browser.table(:id, "theTable")
  #see howmany rows there are, exclude the header
  count = table.row_count_excluding_nested_tables
  @logger.info("assignment_steps.rb: number of rows=#{count} ")
  #traverse the rows
  courseId = 0
  2.upto(count) do |i| 
    row_values = table.row_values(i)
    if (row_values[2] =~ /#{coursename}/)
      @logger.info("assignment_steps.rb: row_values[2] coursename =#{row_values[2]}")
      courseId = WatirUtil.getCourseId(row_values[2])
      @logger.info("assignment_steps.rb: courseId =#{courseId}")
    end
  end
 
  @logger.info("assignment_steps.rb: goto #{WatirConfig.getValue("SERVER_URL")}#{WatirConfig.getValue("ASSIGNMENT_TO_COURSE")}#{assignmentId}")
  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}#{WatirConfig.getValue("ASSIGNMENT_TO_COURSE")}#{assignmentId}")
  @browser.radio(:id, "assignment_course_id_#{courseId}").set
  @browser.button(:value, "Save").click
  @browser.wait
  @logger.info("assignment_steps.rb: assignment_course_id_#{courseId}")

end
 