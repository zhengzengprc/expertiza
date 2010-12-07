class EncryptData < ActiveRecord::Migration
  @@encryption_parameters = {
    #a hash with a value of an array that can hold multiple attributes
    'Users' => ['name', 'fullname', 'email']
  }
  @@model_parameters = {
    'Users' => 'User'
  }

  def self.up
    # Empty out the encrypted vars array so the migration isn't dependant on the current model
    User.send(:class_variable_set, :@@encrypted_vars, Array.new)
    EncryptionMigrationHelper.migrate_up(@@model_parameters, @@encryption_parameters)
  end

  def self.down
    # Empty out the encrypted vars array so the migration isn't dependant on the current model
    User.send(:class_variable_set, :@@encrypted_vars, Array.new)
    EncryptionMigrationHelper.migrate_down(@@model_parameters, @@encryption_parameters)
  end
end

