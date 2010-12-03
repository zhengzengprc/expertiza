############################################################
# These methods are used to manipulate courses in expertiza
############################################################

##########################################################
And /^there is a course created$/ do
end

##########################################################
When /^I go to course (.*) I should be able to create new teams$/ do |coursenameLookup|
  coursename = WatirConfig.getValue(coursenameLookup)
  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}/menu/manage/courses")
  @browser.wait
  @logger.info("course_steps.rb: assume there is a course created already")
  if (@browser.html.include?(coursename))
    @logger.info("course_steps.rb: course #{coursename} found")
  else
    @logger.error("course_steps.rb: course (#{coursename} does not exist)")
    exit
  end
  
  #find the table of courses
  @table = @browser.table(:id, "theTable")
  #see howmany rows there are, exclude the header
  @count = @table.row_count_excluding_nested_tables
  @logger.info("course_steps.rb: number of rows=#{@count} ")
  #traverse the rows
  2.upto(@count) do |i| 
    @row_values = @table.row_values(i)
    if (@row_values[2] =~ /#{coursename}/)
      @logger.info("course_steps.rb: @row_values[2]=#{@row_values[2]}")
      @id = WatirUtil.getCourseId(@row_values[2])
      @logger.info("course_steps.rb: Id = #{@id}")
    end
  end
  
  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}/team/list/#{@id}?type=Course")
  @browser.wait
end

##########################################################
Given /^that there is a course created$/ do
  @logger.info("course_steps.rb: that there is a course created")
end

##########################################################
Then /^I can upload a CSV file (.*) to import teams$/ do |filenameLookup|
  filename = WatirConfig.getValue(filenameLookup)
  @logger.info("course_steps.rb: I can upload a CSV file #{filename}")
   
  if (@browser.link(:text, "Import Teams").exists?)
    @logger.info("course_steps.rb: Import Teams link found")
    @browser.link(:text, "Import Teams").click
	@browser.wait
  else 
    @logger.info("course_steps.rb: Import Teams link is not on page")
	exit
  end
  
  if (@browser.file_field(:name, "file").exists?)
    @logger.info("course_steps.rb: file field is not on page")
    @browser.file_field(:name, "file").set(filename) 
    @browser.button(:value, "Import").click
    @browser.wait
    @logger.info("course_steps.rb: file imported")
  else
    @logger.info("course_steps.rb: file field is not on page")
	exit
  end
end

##########################################################
Then /^I can upload a CSV file (.*) to assign reviewers$/ do |filenameLookup|
  filename = WatirConfig.getValue(filenameLookup)
  @logger.info("course_steps.rb: I can upload a CSV file #{filename}")
   
  if (@browser.link(:text, "Import reviewer mappings").exists?)
    @logger.info("course_steps.rb: Assign reviewer mappings link found")
    @browser.link(:text, "Import reviewer mappings").click
	@browser.wait
  else 
    @logger.info("course_steps.rb: Assign reviewer mappings link is not on page")
	exit
  end
  
  if (@browser.file_field(:name, "file").exists?)
    @logger.info("course_steps.rb: file field is not on page")
    @browser.file_field(:name, "file").set(filename) 
    @browser.button(:value, "Import").click
    @browser.wait
    @logger.info("course_steps.rb: file imported")
  else
    @logger.info("course_steps.rb: file field is not on page")
	exit
  end
end

##########################################################
Given /^I Create a public course$/ do
  @logger.info("Follow link to create public course") 
  @browser.link(:text,"Create Public Course").click
  @browser.wait
end



