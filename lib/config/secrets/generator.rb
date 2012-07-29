require 'digest/sha2'

module Config
  module Secrets
    # Generates secure keys for use as the secret to encrypt your sensitve
    # configuration.
    class Generator

      def initialize
        @hash_function = :sha512
        @iterations = 10_000
        @key_length = 512
      end

      attr_writer :hash_function
      attr_writer :iterations
      attr_writer :key_length

      # Generate a secret key.
      #
      # password - String password for the key.
      # salt     - String salt used to generate the key.
      #
      # Returns a String.
      def generate_key(password, salt)
        sha = Digest::SHA512.new
        pbkdf2 = PBKDF2.new do |p|
          p.password = password
          p.salt = sha.digest(salt)
          p.iterations = @iterations
          p.key_length = @key_length
          p.hash_function = @hash_function
        end
        Base64.encode64(pbkdf2.bin_string)
      end

    end
  end
end
