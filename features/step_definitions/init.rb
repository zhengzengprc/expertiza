require 'firewatir'
require 'capybara/cucumber'

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

### Boot up firefox
  $ff = FireWatir::Firefox.new
  $ff.goto("http://localhost:3000")

# replace true=> false for quick testing
if(true)
  # log in as admin
    # if already logged in, log us out
    if($ff.button(:value, "Logout").exists?)
      $ff.button(:value, "Logout").click
    end
  
    $ff.text_field(:name,"login[name]").set('admin')
    $ff.text_field(:name,"login[password]").set('admin')
    $ff.button(:value,"Login").click
  
  # admin logged in, now, to check and add users
    $ff.link(:text, 'Manage...').fire_event('onmouseover')
    $ff.link(:text, 'Users').click
  
  # create users: BTW -> we're doing this since 
  # fixtures is horrendously broken and we don't have
  # time to fix it ourselves.
  # if nothing else, this proves a good test to create
  # users by hand
  
    $ff.link(:text, 'Manage...').fire_event('onmouseover')
    $ff.link(:text, 'Users').click
  
  # Gehringer
    if($ff.link(:text, 'g').exists?)
      $ff.link(:text, 'g').click
    end
    if(!$ff.link(:text, 'Gehringer').exists?)
      $ff.link(:text, 'New User').click
      $ff.select_list(:name,'user[role_id]').select('Instructor')
      $ff.text_field(:name,'user[name]').set('Gehringer')
      $ff.text_field(:name,'user[fullname]').set('Gehringer')
      $ff.text_field(:name,'user[clear_password]').set('gehringer')
      $ff.text_field(:name,'user[confirm_password]').set('gehringer')
      $ff.button(:name, 'commit').click
    end
  
  # Titus
    if($ff.link(:text, 't').exists?)
      $ff.link(:text, 't').click
    end
    if(!$ff.link(:text, 'Titus').exists?)
      $ff.link(:text, 'New User').click
      $ff.select_list(:name,'user[role_id]').select('Teaching Assistant')
      $ff.text_field(:name,'user[name]').set('Titus')
      $ff.text_field(:name,'user[fullname]').set('Titus')
      $ff.text_field(:name,'user[clear_password]').set('titus')
      $ff.text_field(:name,'user[confirm_password]').set('titus')
      $ff.button(:name, 'commit').click
    end
  
  # mtreece
    if($ff.link(:text, 'm').exists?)
      $ff.link(:text, 'm').click
    end
    if(!$ff.link(:text, 'mtreece').exists?)
      $ff.link(:text, 'New User').click
      $ff.select_list(:name,'user[role_id]').select('Student')
      $ff.text_field(:name,'user[name]').set('mtreece')
      $ff.text_field(:name,'user[fullname]').set('mtreece')
      $ff.text_field(:name,'user[clear_password]').set('mtreece_pw')
      $ff.text_field(:name,'user[confirm_password]').set('mtreece_pw')
      $ff.button(:name, 'commit').click
    end
  
  
  # sjain2
    if($ff.link(:text, 's').exists?)
      $ff.link(:text, 's').click
    end
    if(!$ff.link(:text, 'sjain2').exists?)
      $ff.link(:text, 'New User').click
      $ff.select_list(:name,'user[role_id]').select('Student')
      $ff.text_field(:name,'user[name]').set('sjain2')
      $ff.text_field(:name,'user[fullname]').set('sjain2')
      $ff.text_field(:name,'user[clear_password]').set('sjain2_pw')
      $ff.text_field(:name,'user[confirm_password]').set('sjain2_pw')
      $ff.button(:name, 'commit').click
    end
  
  # nobody
    if($ff.link(:text, 'n').exists?)
      $ff.link(:text, 'n').click
    end
    if(!$ff.link(:text, 'nobody').exists?)
      $ff.link(:text, 'New User').click
      $ff.select_list(:name,'user[role_id]').select('Student')
      $ff.text_field(:name,'user[name]').set('nobody')
      $ff.text_field(:name,'user[clear_password]').set('nobody_pw')
      $ff.text_field(:name,'user[confirm_password]').set('nobody_pw')
      $ff.button(:name, 'commit').click
    end
end
