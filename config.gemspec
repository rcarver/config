# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "config/version"

Gem::Specification.new do |s|
  s.name        = "config"
  s.version     = Config::VERSION
  s.authors     = ["Ryan Carver"]
  s.email       = ["ryan@ryancarver.com"]
  s.homepage    = ""
  s.summary     = %q{A modern server management tool}
  s.description = %q{Config is a ruby and git-based server management tool}

  s.rubyforge_project = "config"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest", "~>2.0"
end
