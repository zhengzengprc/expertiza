require 'encryption_migration_helper'
require 'openssl'
require 'digest/sha1'
class EncryptData < ActiveRecord::Migration
  def self.isEncrypted(attribute)
    #TODO: do check for encryption here
    return false
  end
  def self.isDecrypted(attribute)
    #TODO: do check for decryption here
    return false
  end
  def self.get_key()
    key = "Key"
    return key
  end
  def self.encrypt_val(value, key)
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.encrypt
    cipher.key = Digest::SHA1.hexdigest("expertiz")
    cipher.iv = iv = "ßâd1l624NyËè©³9©" #iv is the initializaton vector
    encrypted_string = cipher.update(value)
    encrypted_string << cipher.final
  end
  def self.decrypt_val(value, key)
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.decrypt
    cipher.key = Digest::SHA1.hexdigest("expertiz")
    cipher.iv = iv = "ßâd1l624NyËè©³9©" #iv is the initializaton vector
    encrypted_string = cipher.update(value)
    encrypted_string << cipher.final  
  end
  def self.up
    #call down to initialize the migration
    #down
    #create a dummy record in the languages table
    #language = Language.create(:name => "Klingon")
    #language.save!

    
    #encryption key
    key = get_key
    #a hash of attributes we need to encrypt in what relations
    encryption_parameters = EncryptionMigrationHelper.get_encryption_parameters
    model_parameters = EncryptionMigrationHelper.get_model_parameters
    #enc_param_key is the relation we want to encrypt attributes in
    encryption_parameters.each_key do |enc_param_key|
      puts 'the relation we are working with is ' + enc_param_key
      #the attributes for this relation we wish to encrypt if need be
      aryAttributes = encryption_parameters[enc_param_key] 
      model = model_parameters[enc_param_key]
      #pull data from the current relation
      @rows = model.constantize.find_by_sql('SELECT * FROM ' + enc_param_key) 
      @rows.each do |r| #r is the current row
        aryAttributes.each do |a| #a is the current attribute
          puts 'attribute we are working with is ' + a
          #unless the attribute is already encrypted we encrypt it now
          unless isEncrypted(r[a])
            #pass the value of the current attribute of the current relation and the encryption key
            enc_a = encrypt_val(r[a], key)
            #update the attribute with the encrypted value
            model.constantize.update_all({a => enc_a}, {:id => r.id.to_s})         
          end
        end
      end
    end
  end
    
  def self.down
    #encryption key
    key = get_key
    #a hash of attributes we need to encrypt in what relations
    encryption_parameters = EncryptionMigrationHelper.get_encryption_parameters
    model_parameters = EncryptionMigrationHelper.get_model_parameters
    
    #enc_param_key is the relation we want to encrypt attributes in
    encryption_parameters.each_key do |enc_param_key|
      #the attributes for this relation we wish to encrypt if need be
      aryAttributes = encryption_parameters[enc_param_key] 
      model = model_parameters[enc_param_key]
      
      #pull data from the current relation
      @rows = model.constantize.find_by_sql('SELECT * FROM ' + enc_param_key) 
      @rows.each do |r| #r is the current row
        aryAttributes.each do |a| #a is the current attribute
          #unless the attribute is already encrypted we encrypt it now
          unless isDecrypted(r[a])
            #pass the value of the current attribute of the current relation and the encryption key
            dec_a = decrypt_val(r[a], key)
            #update the attribute with the encrypted value
            model.constantize.update_all({a => dec_a}, {:id => r.id.to_s}) 
          end
        end
      end
    end
  end
end

