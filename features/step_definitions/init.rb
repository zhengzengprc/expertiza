require 'firewatir'
require 'capybara/cucumber'
#Capybara.app = "make sure this isnt nil"

# patch to make faster typing in text fields
module FireWatir
      class TextField < InputElement
        def doKeyPress( value )
          begin
            max = maxlength
            if (max > 0 && value.length > max)
              original_value = value
              value = original_value[0...max]
              element.log " Supplied string is #{suppliedValue.length} chars, which exceeds the max length (#{max}) of the field. Using value: #{value}"
            end
          rescue
            # probably a text area - so it doesnt have a max Length
          end

          for i in 0..value.length-1
            # sleep element.typingspeed   # typing speed
            c = value[i,1]
            # element.log  " adding c.chr " + c  #.chr.to_s
            @o.value = "#{(@o.value.to_s + c)}"   #c.chr
          end
    #      @o.fireEvent("onKeyDown")
    #      @o.fireEvent("onKeyPress")
    #      @o.fireEvent("onKeyUp")
        end
      end
    end
