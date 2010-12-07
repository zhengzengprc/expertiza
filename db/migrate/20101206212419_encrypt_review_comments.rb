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
    EncryptionMigrationHelper.migrate_up(@@model_parameters, @@encryption_parameters)
  end

  def self.down
    EncryptionMigrationHelper.migrate_down(@@model_parameters, @@encryption_parameters)
  end
end