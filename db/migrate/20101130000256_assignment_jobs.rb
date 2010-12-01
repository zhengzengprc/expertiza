class AssignmentJobs < ActiveRecord::Migration

	def self.up

		create_table :assignment_jobs do |t|

			t.integer :assignment_id

			t.string :job
 
			t.timestamps

		end

	end
 
	def self.down

		drop_table :assigment_jobs

	end

end