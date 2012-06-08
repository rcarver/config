# This file restores `Config` as a functional alias of `RbConfig`. This
# fixes two things:
#   
#   1. By default in ruby `Config.name` = "RbConfig"
#   2. The first time we define `Config` we get a warning on STDERR:
#        "Use RbConfig instead of obsolete and deprecated Config."
#      This warning is to support Ruby 1.8.4 and above, so it is safe
#      to say that we can reclaim the constant `Config` now.
#
# See config/version.rb for the first step of this process: to replace
# the autoload for `Config`, which is where the warning is triggered.
#
# Unfortunately, some libraries (ohai) still use `Config` instead of
# `RbConfig`, so now we have to restore that behavior.

require 'rbconfig'

module Config

  CONFIG = ::RbConfig::CONFIG

  def self.ruby
    RbConfig.ruby
  end
end

