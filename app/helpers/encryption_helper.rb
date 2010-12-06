class CachedData
  # write-only, reads must go through the encrypt/decrypt methods
  # if setting a new value in either field, the other field should subsequently to nil
  attr_writer :cipher_text
  attr_writer :plain_text

  def initialize
    @cipher_text = nil
    @plain_text = nil
  end

  def encrypt(encryptor, key)
    # return cached value if it exists
    if(@cipher_text != nil)
      puts "Encryption: Returned Cached Value"
      return @cipher_text
    end

    # encrypt the value and cache it for future calls
    if(encryptor != nil)
      puts "Encryption: Encrypted Value"
      @cipher_text = encryptor.encrypt_val(@plain_text, key)
    end

    return @cipher_text
  end

  def decrypt(encryptor, key)
    # return cached value if it exists
    if(@plain_text != nil)
      puts "Decryption: Returned Cached Value"
      return @plain_text
    end

    # decrypt the value and cache it for future calls
    if(encryptor != nil)
      puts "Decryption: Decrypted Value"
      @plain_text = encryptor.decrypt_val(@cipher_text, key)
    end

    return @plain_text
  end
end

class AES256Encrypter
  def encrypt_val(value, key)
    if(value == nil)
      return nil
    end

    if(value.empty?)
      return value
    end

    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.encrypt
    c.key = key
    c.iv = "?Çd1l624Ny¿À©?9©"
    result_value = c.update(value)
    result_value << c.final

    return result_value
  end

  def decrypt_val(value, key)
    if(value == nil)
      return nil
    end

    if(value.empty?)
      return value
    end

    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.decrypt
    c.key = key
    c.iv = "?Çd1l624Ny¿À©?9©"
    result_value = c.update(value)
    result_value << c.final 

    return result_value
  end
end

module EncryptionHelper
  #after_save :decrypt_callback
  #after_find :decrypt_callback

  def included(klass)
    super
  end

  def encrypt()
    puts "Encryption callback"
    key = EncryptionHelper.get_key()
    encrypt_with_key(key)
  end

  def decrypt()
    puts "Decryption callback"
    key = EncryptionHelper.get_key()
    decrypt_with_key(key)
  end

  def EncryptionHelper.get_key()
    key = Digest::SHA1.hexdigest("expertiz")
    return key
  end

  def encrypt_with_key(key)
    encrypter = AES256Encrypter.new

    for encrypted_var in self.class.send(:class_variable_get, :@@encrypted_vars)
      value = self.send(encrypted_var)

      encryption_cache = obtain_encryption_cache()
      cache_entry = encryption_cache[encrypted_var]
      if(cache_entry == nil)
        cache_entry = CachedData.new
        encryption_cache[encrypted_var] = cache_entry
        cache_entry.plain_text = value
        cache_entry.cipher_text = nil
      end

      puts "Encrypting" + value.to_s
      value = cache_entry.encrypt(encrypter, key)
      puts "Result" + value.to_s
      self.send(encrypted_var + "=", value)
    end
  end

  def decrypt_with_key(key)
    encrypter = AES256Encrypter.new

    array_test = self.class.send(:class_variable_get, :@@encrypted_vars)
    puts array_test.class
    puts array_test.size

    for encrypted_var in self.class.send(:class_variable_get, :@@encrypted_vars)
      value = self.send(encrypted_var)

      encryption_cache = obtain_encryption_cache()
      cache_entry = encryption_cache[encrypted_var]
      if(cache_entry == nil)
        cache_entry = CachedData.new
        encryption_cache[encrypted_var] = cache_entry
        cache_entry.plain_text = nil
        cache_entry.cipher_text = value
      end

      puts "Decrypting" + value.to_s
      value = cache_entry.decrypt(encrypter, key)
      puts "Result" + value.to_s
      self.send(encrypted_var + "=", value)
    end
  end

  def obtain_encryption_cache()
    # Get the existing encryption cache
    encryption_cache = self.instance_variable_get(:@__encryption_cache)

    # Create an empty cache if none was found
    if(encryption_cache == nil)
      encryption_cache = Hash.new
      self.instance_variable_set(:@__encryption_cache, encryption_cache)
    end

    return encryption_cache
  end
end