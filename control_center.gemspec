# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "control_center/version"

Gem::Specification.new do |s|  
  s.name = "control_center"
  s.version = ControlCenter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author = "Steve Randy Tantra"
  s.email = "mail@steverandytantra.com"
  s.homepage = "http://steverandytantra.com"
  s.summary = "Control Center"
  s.description = "Control and monitor website."
  
  s.rubyforge_project = "control_center"
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency("compass", "0.10.6")
  s.add_dependency("haml", ">=3.1.0.alpha.147")
  s.add_dependency("devise", "~>1.2.0")
  s.add_dependency("mongoid", ">=2.0.0.beta.20")
  s.add_dependency("bson_ext", ">=1.1.2")
  s.add_dependency("uuid", ">=2.3.1")
  s.add_dependency("whenever", "~>0.6.2")
end