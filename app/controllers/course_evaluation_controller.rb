class CourseEvaluationController < ApplicationController
require 'aquarium'

  def list #list course evaluations for a user
    unless session[:user] #Check for a valid user
      redirect_to '/'
      return 
    end    
    deployments=SurveyParticipant.find_all_by_user_id(session[:user].id)
    @surveys=Array.new
    deployments.each do |sd|
      survey_deployment=SurveyDeployment.find(sd.survey_deployment_id)
      if(Time.now>survey_deployment.start_date && Time.now<survey_deployment.end_date)
        @surveys<<[Questionnaire.find(survey_deployment.course_evaluation_id),sd.survey_deployment_id,survey_deployment.end_date, survey_deployment.course_id]
      end
     end
   end
include Aquarium::DSL
  around :methods => [:list] do |join_point, object, *args|
    logger.info "[info] Entering: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result = join_point.proceed
    logger.info "[info] Leaving: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result  # block needs to return the result of the "proceed"!
  end
  
end
