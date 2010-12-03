################################################################
# These methods are generic for webpages 
################################################################

#################################################
# Text Fields
#################################################
Given /^I fill in the text_field "(.*)" with "(.*)"/ do |id,text|
  @browser.text_field(:id,id).set(text)  
end

#################################################
# Button Manipulation
#################################################
Given /^I click the "(.*)" button/ do |value|
  @logger.info("generic_web_steps.rb: clicking on button "+value) 
  @browser.button(:value,value).click
  @browser.wait
end

#################################################
Then /^I click "([^"]*)" button$/ do |arg1|
  @logger.info("generic_web_steps.rb: clicking on button "+arg1) 
  @browser.button(:value,arg1).click
  @browser.wait
end

#################################################
# Web GUI Checks
#################################################
Given /I verify that the page contains the text "(.*)"/ do |text|
  if (!(@browser.html.include? text))
    @logger.error("generic_web_steps.rb: the text (#{text} does not exist)")
    exit
  end
end

#################################################
Given /^I verify that page does not contain the text "([^"]*)"$/ do |arg1|
  if (!(@browser.html.include? arg1))
    @logger.error("generic_web_steps.rb: the text (#{arg1} does not exist)")
    exit
  end
end

#################################################
And /^I navigate to the (.*)$/ do |lookupurl|
  navurl = WatirConfig.getValue(lookupurl)
  @logger.info("generic_web_steps.rb: navigate to the url #{navurl}")
  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}#{navurl}")
  @browser.wait
end

