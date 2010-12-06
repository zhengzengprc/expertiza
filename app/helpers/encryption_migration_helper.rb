module EncryptionMigrationHelper
  @@encryption_parameters = {
    #a hash with a value of an array that can hold multiple attributes
    'Users' => ['name', 'fullname']
  }
  @@model_parameters = {
    'Users' => 'User'
  }
  
  def EncryptionMigrationHelper.get_encryption_parameters
    return @@encryption_parameters
  end
  
  def EncryptionMigrationHelper.get_model_parameters
    return @@model_parameters
  end
end