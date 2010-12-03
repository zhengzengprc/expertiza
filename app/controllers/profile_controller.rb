#Allows a user to update their own profile information
class ProfileController < ApplicationController

#load the view with the current fields
#only valid if user is logged in
 def edit 
    @user = session[:user]    
    @user.confirm_password = ''   
    @assignment_questionnaires = AssignmentQuestionnaires.find(:first, :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null',@user.id])    
	
    # E03 task list functionality get task preference for the user
    @taskf = TaskGray.find_by_userid(@user.id)
 end
  
 #store parameters to user object
 def update
    @user = session[:user]
    
    unless params[:assignment_questionnaires].nil? or params[:assignment_questionnaires][:notification_limit].blank?
      aq = AssignmentQuestionnaires.find(:first, :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null',@user.id])
      aq.update_attribute('notification_limit',params[:assignment_questionnaires][:notification_limit])                    
    end
    
	# E03 task list functionality create new task preference is not already there
    if @taskf.nil?
       new_task=TaskGray.new
       new_task.userid=@user.id
       new_task.grayed= params[:RadioAddition][:check]
       new_task.save
    else # else update based on user selection
        @taskf.update_attribute(:grayed,params[:RadioAddition][:check])
    end
    
	
    if params[:user][:clear_password].blank?
      params[:user].delete('clear_password')
    end

    if !params[:user][:clear_password].blank? and
        params[:user][:confirm_password] != params[:user][:clear_password]
      flash[:error] = 'Password does not match.'
      render :action => 'edit' 
    else
      if @user.update_attributes(params[:user])
        flash[:note] = 'Profile was successfully updated.'
        redirect_to :action => 'edit', :id => @user
      else
        flash[:note] = 'Profile was not updated.'
        render :action => 'edit'
      end
    end
  end

end
