class AddTypeToAssignmentQuestionnaires < ActiveRecord::Migration

	def self.up

		add_column :assignment_questionnaires, :questionnaire_type, :string, :null => true
		
	end

	def self.down
	
	end

end