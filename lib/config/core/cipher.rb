require 'base64'
require 'openssl'

module Config
  module Core
    # Cipher encrypts and decrypts information using a secret key.
    class Cipher

      def initialize(key)
        @key = key
        @cipher = OpenSSL::Cipher::AES128.new(:CBC)
      end

      # Encrypt a string using the key.
      #
      # value - String to encrypt.
      #
      # Returns a String.
      def encrypt(value)
        encryptor = @cipher.encrypt
        encryptor.key = @key
        Base64.encode64(encryptor.update(value) + encryptor.final)
      end

      # Decrypt a string using the key.
      #
      # value - String to decrypt.
      #
      # Returns a String.
      def decrypt(value)
        decryptor = @cipher.decrypt
        decryptor.key = @key
        decryptor.update(Base64.decode64(value)) + decryptor.final
      end

    end
  end
end
