require 'digest/sha1'
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
        @salt = "default"
      end

      attr_writer :hash_function
      attr_writer :iterations
      attr_writer :key_length
      attr_writer :salt

      # Get the partition that secrets created by this generator belong to.
      # The partition is calculated from the settings on this generator and is
      # thus distinct for any unique combination of settings.
      #
      # Returns a String.
      def partition
        key = [@hash_function, @iterations, @key_length, @salt].join(':')
        Digest::SHA1.hexdigest(key)
      end

      # Generate a key.
      #
      # password - String password for the key.
      #
      # Returns a String.
      def generate_key(password)
        pbkdf2 = PBKDF2.new do |p|
          p.password = password
          p.salt = Digest::SHA512.digest(@salt)
          p.iterations = @iterations
          p.key_length = @key_length
          p.hash_function = @hash_function
        end
        Base64.encode64(pbkdf2.bin_string)
      end

    end
  end
end
