################################################################
# These methods are used to manipulate teams in to expertiza 
################################################################

##########################################################
When /^I go to edit my team$/ do
  #find your team link and click on it
  @logger.info("team_steps.rb: edit the team")
  if (@browser.link(:text, "Your team").exists?)
    @browser.link(:text, "Your team").click
    @browser.wait
    @logger.info("team_steps.rb: Your team clicked")
  else
    @logger.error("team_steps.rb: Your team link does not exist")
    exit
  end
end

##########################################################
And /^create a team name and name it (.*)$/ do |teamnameLookup|
  teamname = WatirConfig.getValue(teamnameLookup)
  
  #update the team name
  @logger.info("team_steps.rb: change the team name to #{teamname}")
  @browser.text_field(:name, "team[name]").set(teamname)
  @browser.button(:name, "commit").click
  @browser.wait
  
  if (@browser.html.include?("#{teamname}"))
    @logger.info("team_steps.rb: Team (#{teamname}) created")
  else
    @logger.error("team_steps.rb: Team (#{teamname}) not created")
    exit  
  end
end

##########################################################
And /^invite some members (.*)$/ do |teamusersLookup|
  teamusers = WatirConfig.getValue(teamusersLookup)
   
  #invite the following users to the team
  for i in 1..teamusers.size do
    @logger.info("team_steps.rb: invide some members")
    @browser.text_field(:name, "user[name]").set(teamusers[i-1])
    @browser.button(:value, "Invite").click
    @browser.wait 
  end  
end

##########################################################
Then /^I should see that the members (.*) are pending$/ do |teamusersLookup|
  teamusers = WatirConfig.getValue(teamusersLookup)
   
  #check to see that the following usernames are pending for the team
  @logger.info("team_steps.rb: see users pending")
  for i in 1..teamusers.size do
    if (@browser.html.include?("#{teamusers[i-1]}"))
      @logger.info("team_steps.rb: user (#{teamusers[i-1]}) added to team")
    else
      @logger.error("team_steps.rb: user (#{teamusers[i-1]}) not added to team")
    end
  end  
end

##########################################################
And /^I leave the team$/ do
  #click on leave team to remove user from team
  @logger.info("Leaving the team")
  if (@browser.link(:text, "Leave Team").exists?)
    @browser.link(:text, "Leave Team").click
    @browser.wait
    @logger.info("team_steps.rb: Leave Team clicked")
  else
    @logger.error("team_steps.rb: Leave Team does not exist)")
    exit
  end
end

##########################################################
Then /^I should see that I have an invite pending$/ do
  #check to see if user needs to Accept eula
  if (@browser.link(:text, "Accept").exists?)
	@browser.link(:text, "Accept").click	
    @browser.wait
  end
  @logger.info("team_steps.rb: clicked Accept")
end

##########################################################
And /^make sure the teams (.*) are created$/ do |teamsLookup|
  @logger.info("team_steps.rb: make sure the teams are created")
  teams = WatirConfig.getValue(teamsLookup)
    
  for i in 1..teams.size do
    if (@browser.html.include?("#{teams[i-1]}"))
      @logger.info("team_steps.rb: team (#{teams[i-1]}) was imported to course")
    else
      @logger.error("team_steps.rb: team (#{teams[i-1]}) was not imported to course")
    end
  end  
end


