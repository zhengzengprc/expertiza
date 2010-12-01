class AddJobToAssignmentQuestionnaires < ActiveRecord::Migration

	def self.up

		add_column :assignment_questionnaires, :questionnaire_job, :string, :null => true
		
	end

	def self.down
	
	end

end