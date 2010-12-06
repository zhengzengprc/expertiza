class EncryptData < ActiveRecord::Migration
  @@encryption_parameters = {
    #a hash with a value of an array that can hold multiple attributes
    'Users' => ['name', 'fullname', 'email']
  }
  @@model_parameters = {
    'Users' => 'User'
  }

  def self.up
    EncryptionMigrationHelper.migrate_up(@@model_parameters, @@encryption_parameters)
  end

  def self.down
    EncryptionMigrationHelper.migrate_down(@@model_parameters, @@encryption_parameters)
  end
end

