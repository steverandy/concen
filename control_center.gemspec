# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "control_center/version"

Gem::Specification.new do |s|  
  s.name = "control_center"
  s.version = ControlCenter::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Steve Randy Tantra"]
  s.email = ["mail@steverandytantra.com"]
  s.homepage = "http://steverandytantra.com"
  s.summary = %q{Control and monitor website.}
  s.description = %q{This gem provides a Rails engine for Rails application to control and monitor the application from a web interface. It covers controlling content, monitoring visitors, and monitoring application performance. The engine is flexible in term of form and function. It can be styled and have custom functions. }
  
  s.files = Dir["README", "MIT-LICENSE", "config/routes.rb", "init.rb", "lib/**/*", "app/**/*", "public/control_center/**/*"]
  s.require_paths = ["lib"]
  
  s.add_development_dependency("compass", "0.10.6")
  s.add_dependency("haml", ">=3.1.0.alpha.147")
  s.add_dependency("devise", "~>1.2.0")
  s.add_dependency("mongoid", ">=2.0.0.beta.20")
  s.add_dependency("bson_ext", ">=1.1.2")
  s.add_dependency("uuid", ">=2.3.1")
  s.add_dependency("whenever", "~>0.6.2")
end