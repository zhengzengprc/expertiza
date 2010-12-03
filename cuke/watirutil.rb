require 'watir'
require 'log4r'

module WatirUtil
  def self.login(logger, browser, username, password)
    logger.info("WatirUtil::login: enter")
    if (browser.button(:value, "Logout").exists?)
      logger.info("WatirUtil::login: found logout button")
    else
      logger.info("WatirUtil::login: logging in")
      logger.info("WatirUtil::login: username=#{username}")
      browser.text_field(:name, "login[name]").set(username)
      logger.info("WatirUtil::login: password=#{password}")
      browser.text_field(:name, "login[password]").set(password)
      browser.button(:name, "commit").click 
    end
	
	#check to see if user needs to Accept eula
    if (browser.link(:text, "Accept").exists?)
	  browser.link(:text, "Accept").click
      logger.info("WatirUtil::login: clicked Accept") 
	  browser.wait
    end
    logger.info("WatirUtil::login: exit")
  end
  
  def self.getCourseId(courseInfo)
    id_begin = courseInfo.index("Id:") + 4
    cd_begin = courseInfo.index("Creation Date:") - 1
    id = courseInfo[id_begin..cd_begin]
    id = id.chomp
    id = id.gsub(/ /,'')
    id = id.gsub(/\n/,'')
  end
end

