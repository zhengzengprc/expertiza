class PasswordRetrievalController < ApplicationController
require 'aquarium'

  def forgotten
  end
 
  def send_password
    if params[:user][:email].nil? or params[:user][:email].strip.length == 0
      flash[:pwerr] = "Please enter an e-mail address"     
    else
      user = User.find_by_email(params[:user][:email])
      if user != nil
        clear_password = ParticipantsHelper.assign_password(8)
        user.send_password(clear_password)    
        flash[:pwnote] = "A new password has been sent to your e-mail address."
      else
        flash[:pwerr] = "No account is associated with the address, \""+params[:user][:email]+"\". Please try again."
      end
    end
    redirect_to :action => 'forgotten'
   end 

include Aquarium::DSL
  around :methods => [:forgotten, :send_password ] do |join_point, object, *args|
    logger.info "[info] Entering: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result = join_point.proceed
    logger.info "[info] Leaving: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result  # block needs to return the result of the "proceed"!
  end
  
end
