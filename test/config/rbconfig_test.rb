require 'helper'

describe RbConfig do 
  
  specify "RbConfig::CONFIG exists" do
    RbConfig::CONFIG.must_be_instance_of(Hash)
    Config::CONFIG.must_be_instance_of(Hash)
  end

  specify "RbConfig.ruby exists" do
    RbConfig.must_respond_to :ruby
    Config.must_respond_to :ruby
  end
end
