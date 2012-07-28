require 'helper'

describe Config::Core::Cipher do

  let(:key) { "shhhh" * 10 }

  subject { Config::Core::Cipher.new(key) }

  it "encrypts and decrypts" do
    encrypt = subject.encrypt("hello world")
    encrypt.must_equal "E4GjScJe1uw8pSJmjNNXyw==\n"
    decrypt = subject.decrypt(encrypt)
    decrypt.must_equal "hello world"
  end
end
