#####################################
# common code for all of the project
#####################################

#main gems required
require 'watir'
require 'log4r'

#project utilities and variables
load 'watirutil.rb'
load 'watirconfig.rb'

#used to try to interact with Javascript Alert popups
require 'watir\contrib\enabled_popup'

##########################################################
Before do
  #do before stuff here 
end
