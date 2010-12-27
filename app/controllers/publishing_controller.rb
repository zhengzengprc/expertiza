class PublishingController < ApplicationController
  require 'aquarium'
  
  def view   
    @participants = AssignmentParticipant.find_all_by_user_id(session[:user].id)
  end
  
  def set_master_publish_permission
    session[:user].update_attribute('master_permission_granted',params[:id])    
    redirect_to :action => 'view'
  end
  
  def set_publish_permission
    participant = AssignmentParticipant.find(params[:id])
    participant.update_attribute('permission_granted',params[:allow])  
    redirect_to :action => 'view'
  end  
  
  def update_publish_permissions
    participants = AssignmentParticipant.find_all_by_user_id(session[:user].id)
    participants.each{
      | participant |
      participant.update_attribute('permission_granted',params[:allow])  
    }    
    redirect_to :action => 'view'
  end
  
  include Aquarium::DSL
  around :methods => [:view, :set_master_publish_permission, :set_publish_permission, :update_publish_permissions] do |join_point, object, *args|
    logger.info "[info] Entering: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result = join_point.proceed
    logger.info "[info] Leaving: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result  # block needs to return the result of the "proceed"!
  end
  
end
