class ExportFileController < ApplicationController
  require 'fastercsv'
  require 'aquarium'
  
  def start    
    filename = "out.csv"
    csv_data = FasterCSV.generate do |csv|
        csv << Object.const_get(params[:model]).get_export_fields()       
               
        Object.const_get(params[:model]).export(csv,params[:id])       
    end
       
    send_data csv_data, 
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{filename}"              
  end
  
include Aquarium::DSL
  around :methods => [:start] do |join_point, object, *args|
    logger.info "[info] Entering: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result = join_point.proceed
    logger.info "[info] Leaving: #{join_point.target_type.name}##{join_point.method_name}: object = #{object}, args = #{args}" 
    result  # block needs to return the result of the "proceed"!
  end
  
end
