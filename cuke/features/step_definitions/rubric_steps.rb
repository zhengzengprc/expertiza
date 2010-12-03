################################################################
# These methods are used to help with sign up sheets in expertiza
################################################################

##########################################################
Given /^I click on menu "(.*)"$/ do |option|
  @logger.info("rubric_steps.rb: click menu item for "+option) 
  @browser.link(:text,option).click
  @browser.wait
end

