class EulaController < ApplicationController
  require 'aquarium'
  
  def display    
  end
  
  def accept
    session[:user].update_attribute('is_new_user',0)
    redirect_to :controller => 'student_task', :action => 'list'
  end
  
  def decline
    flash[:notice] = 'Please accept the license agreement in order to use the system.'
    redirect_to :action => 'display'    
  end

include Aquarium::DSL
  around :methods => [:display, :accept, :decline] do |join_point, object, *args|
    logger.info "[info] Entering: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result = join_point.proceed
    logger.info "[info] Leaving: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result  # block needs to return the result of the "proceed"!
  end
  
  
end
