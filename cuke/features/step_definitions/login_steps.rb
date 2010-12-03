################################################################
# These methods are used to log in to expertiza 
################################################################

##########################################################
Given /^a browser is open to Expertiza with logging (.*)$/ do |filename|
  #create the logger
  @logger = Logger.new(filename)
  @logger.info("login_steps.rb: Creating browser to URL: #{WatirConfig.getValue("SERVER_URL")}")
  @browser = Watir::Browser.start(WatirConfig.getValue("SERVER_URL"))
  @browser.wait
end

##########################################################
And /^I am logged into Expertiza as an Admin$/ do
  #login to Expertiza as admin user
  @logger.info("login_steps.rb: Loggin in as user #{WatirConfig.getValue("ADMIN_USERNAME")} and password #{WatirConfig.getValue("ADMIN_PASSWORD")}")
  WatirUtil.login(@logger, @browser, WatirConfig.getValue("ADMIN_USERNAME"), WatirConfig.getValue("ADMIN_PASSWORD"))
  @browser.wait
end

##########################################################
And /^I am logged into Expertiza as (.*) with password (.*)$/ do |usernameLookup, passwordLookup|
  username = WatirConfig.getValue(usernameLookup)
  password = WatirConfig.getValue(passwordLookup)
  #login to Expertiza as specified user
  @logger.info("login_steps.rb: Loggin in as user #{username} and password #{password}")
  WatirUtil.login(@logger, @browser, username, password)
  @browser.wait
end

##########################################################
And /^I close the browser$/ do
  #close browser
  @logger.info("login_steps.rb: Closing browser as part of cleanup")
  @browser.close
end