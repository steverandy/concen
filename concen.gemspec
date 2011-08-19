# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "concen/version"

Gem::Specification.new do |s|
  s.name = "concen"
  s.version = Concen::VERSION
  s.authors = ["Steve Randy Tantra"]
  s.email = ["steve.randy@gmail.com"]
  s.homepage = ""
  s.summary = %q{Control and monitor Rails application.}
  s.description = %q{This gem provides a Rails engine for Rails application to control and monitor the application from a web interface. It covers controlling content, monitoring visitors, and monitoring application performance. The engine is flexible in term of form and function. It can be styled and have custom functions. }

  s.rubyforge_project = "concen"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("compass", "0.11.5")
  s.add_dependency("haml", "~> 3.1.0")
  s.add_dependency("mustache", "~> 0.99.4")
  s.add_dependency("redcarpet", "~> 2.0.0b3")
  s.add_dependency("mongoid", "~> 2.0.0")
  s.add_dependency("mongo-rails-instrumentation", "~> 0.2.4")
  s.add_dependency("bson_ext", "~> 1.3.0")
  s.add_dependency("rack-gridfs", "~> 0.4.1")
  s.add_dependency("chronic", "~> 0.4.3")
  s.add_dependency("mime-types", "~> 1.16")
  s.add_dependency("bcrypt-ruby", "~> 2.1.4")
  s.add_dependency("domainatrix", "~> 0.0.10")
end
