class EncryptReviewComments < ActiveRecord::Migration
  @@encryption_parameters = {
    'Scores' => ['comments'],
    'Responses' => ['additional_comment']
  }
  @@model_parameters = {
    'Scores' => 'Score',
    'Responses' => 'Response'
  }

  def self.up
    # Empty out the encrypted vars array so the migration isn't dependant on the current model
    Score.send(:class_variable_set, :@@encrypted_vars, Array.new)
    Response.send(:class_variable_set, :@@encrypted_vars, Array.new)
    EncryptionMigrationHelper.migrate_up(@@model_parameters, @@encryption_parameters)
  end

  def self.down
    # Empty out the encrypted vars array so the migration isn't dependant on the current model
    Score.send(:class_variable_set, :@@encrypted_vars, Array.new)
    Response.send(:class_variable_set, :@@encrypted_vars, Array.new)
    EncryptionMigrationHelper.migrate_down(@@model_parameters, @@encryption_parameters)
  end
end