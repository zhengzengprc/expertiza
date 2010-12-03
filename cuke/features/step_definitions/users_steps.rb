##########################################################
# These methods are used to manipulate users in expertiza
##########################################################

##########################################################
And /^there are other members of expertiza$/ do
  @logger.info("user_steps.rb: assume there are other members of Expertiza")
end

When /^I go to manage users$/ do
  #navigate to manage users
  if (@browser.html.include?("Manage content") || @browser.html.include?("Welcome to Expertiza"))
    @logger.info("user_steps.rb: manage users")
    @browser.goto("#{WatirConfig.getValue("SERVER_URL")}/menu/manage/users")
    @browser.wait
  else
    @logger.error("user_steps.rb: unable to manage users")
    exit
  end

  if (@browser.html.include?("Manage users"))
    @logger.info("user_steps.rb: Manage users exists")
  else
    @logger.error("user_steps.rb: Manage users does not exist)")
    exit
  end
end

##########################################################
And /^I want to create (.*) users with the name (.*)$/ do |howManyLookup, usernameLookup|
  #create x number of users  
  howMany = WatirConfig.getValue(howManyLookup)
  username = WatirConfig.getValue(usernameLookup)
  
  for i in 1..howMany.to_i do
    if (@browser.link(:text, "New User").exists?)
      @browser.link(:text, "New User").click
      @browser.wait
      @logger.info("user_steps.rb: New User clicked")
    else
      @logger.error("user_steps.rb: New User does not exist)")
      exit
    end
    @logger.info("user_steps.rb: add #{username}#{i}")
    role = @browser.select_list(:name, "user[role_id]")
    role.select("Student")
    @browser.text_field(:name, "user[name]").set("#{username}#{i}")
    @browser.text_field(:name, "user[fullname]").set("#{i}, #{username}")
    @browser.text_field(:name, "user[email]").set("#{username}#{i}@users.com")
    @browser.text_field(:name, "user[clear_password]").set("#{username}#{i}")
    @browser.text_field(:name, "user[confirm_password]").set("#{username}#{i}")
    @browser.checkbox(:name, "user[email_on_review]").set
    @browser.checkbox(:name, "user[email_on_submission]").set
    @browser.checkbox(:name, "user[email_on_review_of_review]").set
    @browser.checkbox(:name, "user[leaderboard_privacy]").set    
    @browser.button(:name, "commit").click
    @browser.wait
  end
end

##########################################################
Then /^make sure the (.*) users with the name (.*) were created$/ do |howManyLookup, usernameLookup|
  #chech for x number of users  
  howMany = WatirConfig.getValue(howManyLookup)
  username = WatirConfig.getValue(usernameLookup)

  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}/users/list")
  @browser.wait
  #go to the group for the created users
  firstLetter = username[0].chr
  @browser.link(:text, "#{firstLetter}").click
  
  for i in 1..howMany.to_i do
    if (@browser.link(:text, "#{username}#{i}").exists?)
      @logger.info("user_steps.rb: user #{username}#{i} exists")
    else
      @logger.error("user_steps.rb: user #{username}#{i} does not exist)")
    end
  end
end

##########################################################
And /^delete the (.*) users with the name (.*)$/ do |howManyLookup, usernameLookup|
  #delete x number of users  
  howMany = WatirConfig.getValue(howManyLookup)
  username = WatirConfig.getValue(usernameLookup)

  @browser.goto("#{WatirConfig.getValue("SERVER_URL")}/users/list")
  @browser.wait

  #go to the group for the created users
  firstLetter = username[0].chr

  for i in 1..howMany.to_i do
    @browser.link(:text, "#{firstLetter}").click
    deleteUser "#{username}#{i}"
  end
end

##########################################################
def deleteUser username
  if (@browser.link(:text, "#{username}").exists?)
    @logger.info("user_steps.rb: user #{username} exists")
    @browser.link(:text, "#{username}").click
    @browser.wait
#    @browser.link(:text, "Delete").click
#      
#    #handle the delete javascript alert
#    hwnd = @browser.enabled_popup(5)
#    if (hwnd)  # yes there is a popup
#      popup = WinClicker.new
#      popup.makeWindowActive(hwnd)
#      popup.clickWindowsButton_hwnd(hwnd, "OK")
#    end
#      
#    @browser.wait
  else
    @logger.error("user_steps.rb: user #{username} does not exist)")
  end
end
