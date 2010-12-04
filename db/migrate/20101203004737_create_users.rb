class CreateUsers < ActiveRecord::Migration
  def self.up
       
      add_column :users, :login, :string, :limit => 40
      add_column :users, :crypted_password, :string, :limit => 40
      add_column :users, :salt,  :string, :limit => 40
      add_column :users, :created_at, :datetime
      add_column :users, :updated_at, :datetime
      add_column :users, :remember_token, :string, :limit => 40
      add_column :users, :remember_token_expires_at, :datetime


    add_index :users, :login, :unique => true
  end

   def self.down

     remove_column :users, :login, :string, :limit => 40
     remove_column :users, :crypted_password, :string, :limit => 40
     remove_column :users, :salt,  :string, :limit => 40
     remove_column :users, :created_at, :datetime
     remove_column :users, :updated_at, :datetime
     remove_column :users, :remember_token, :string, :limit => 40
     remove_column :users, :remember_token_expires_at, :datetime


     remove_index :users, :unique => true
   
  end
end
