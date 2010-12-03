############################################################
# These methods are used to manipulate signups in expertiza
############################################################

##########################################################
Given /^Given that assignment (.*) is listed$/ do |arg1|
  #assert(@browser.html.include? arg1)
  @logger.info("signup_sheet_steps.rb: " + arg1 + " is listed")
end

##########################################################
Given /^I create a sign up sheet of first assignment$/ do
  @logger.info("signup_sheet_steps.rb: creating sign up sheet")
  @browser.link(:text,"Add signup sheet").click
  @browser.wait
end

##########################################################
Given /^I edit sign up sheet of first assignment$/ do
  @logger.info("signup_sheet_steps.rb: editing sign up sheet")
  @browser.link(:text,"Edit signup sheet").click
  @browser.wait
end

##########################################################
Given /^I input "([^"]*)" with "([^"]*)"$/ do |arg1, arg2|
  @logger.info("signup_sheet_steps.rb: entering csv file location")
  #file = (File.dirname(File.expand_path(__FILE__)) + '\\'+arg2).gsub! '/', '\\'
  @browser.file_field(:id, arg1).set(arg2).select(3).click
  @browser.wait
end

##########################################################
Given /^If an existing sign up sheet is displayed$/ do
  @looger.info("signup_sheet_steps.rb: editing existing sign up sheet")
  assert(@browser.html.include? "Signup sheet")
end

##########################################################
Given /^that I have gone to the manage assignment page$/ do
  @logger.info("signup_sheet_steps.rb: going to manage assignment page")   
  @browser = Watir::Browser.start"#{WatirConfig.getValue("SERVER_URL")}/tree_display/list"
  @browser.wait
end

##########################################################
Given /^I edit text field submission_1 to "(.*)"$/ do |arg1|   
  @browser.text_field(:id,/submission_1/).set(arg1)
  @logger.info("signup_sheet_steps.rb: submission deadline modified")
end

##########################################################
Given /^I click on signup action$/ do
  @browser.link(:url,/signup/).click
  @logger.info("signup_sheet_steps.rb: signed up for topic") 
end

##########################################################
Given /^I verify that the page contains cancel action$/ do
  assert(@browser.html.include? "Delete_icon")
  @logger.info("signup_sheet_steps.rb: successfully signed up for topic")
end

##########################################################
Given /^Given that assignment (.*) is listed$/ do |arg1|
  assert(@browser.html.include? arg1)
  @logger.info("signup_sheet_steps.rb: " + arg1 + " is listed")
end
