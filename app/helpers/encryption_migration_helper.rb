require 'encryption_helper'
require 'openssl'
require 'digest/sha1'

module EncryptionMigrationHelper
  def EncryptionMigrationHelper.get_key()
    key = Digest::SHA1.hexdigest("expertiz")
    return key
  end
  
  def EncryptionMigrationHelper.migrate_up(model_parameters, encryption_parameters)
    key = EncryptionMigrationHelper.get_key()

    encrypter = AES256Encrypter.new

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
          #pass the value of the current attribute of the current relation and the encryption key
          enc_a = encrypter.encrypt_val(r[a], key)
          #update the attribute with the encrypted value
          model.constantize.update_all({a => enc_a}, {:id => r.id.to_s})
        end
      end
      
      # update the class encrypted_vars array
      model_encrypted_vars = model.constantize.send(:class_variable_get, :@@encrypted_vars)
      for new_encrypted_var in aryAttributes
        # add the encrypted elements
        model_encrypted_vars << new_encrypted_var
      end
      model.constantize.send(:class_variable_set, :@@encrypted_vars, model_encrypted_vars)
    end
  end

  def EncryptionMigrationHelper.migrate_down(model_parameters, encryption_parameters)
    key = EncryptionMigrationHelper.get_key()

    encrypter = AES256Encrypter.new

    #enc_param_key is the relation we want to encrypt attributes in
    encryption_parameters.each_key do |enc_param_key|
      #the attributes for this relation we wish to encrypt if need be
      aryAttributes = encryption_parameters[enc_param_key]
      model = model_parameters[enc_param_key]

      #pull data from the current relation
      @rows = model.constantize.find_by_sql('SELECT * FROM ' + enc_param_key)
      @rows.each do |r| #r is the current row
        aryAttributes.each do |a| #a is the current attribute
          #pass the value of the current attribute of the current relation and the encryption key
          dec_a = encrypter.decrypt_val(r[a], key)
          #update the attribute with the encrypted value
          model.constantize.update_all({a => dec_a}, {:id => r.id.to_s})
        end
      end

      # update the class encrypted_vars array
      model_encrypted_vars = model.constantize.send(:class_variable_get, :@@encrypted_vars)
      for new_encrypted_var in aryAttributes
        #remove the specified elements
        model_encrypted_vars.delete(new_encrypted_var)
      end
      model.constantize.send(:class_variable_set, :@@encrypted_vars, model_encrypted_vars)
    end
  end
end