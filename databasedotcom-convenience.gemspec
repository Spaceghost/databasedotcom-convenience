# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "databasedotcom/convenience/version"

Gem::Specification.new do |s|
  s.name        = "databasedotcom-convenience"
  s.version     = Databasedotcom::Convenience::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Danny Burkes, Johnneylee Jack Rollins"]
  s.email       = ["Johnneylee.Rollins@gmail.com"]
  s.homepage    = "http://github.com/Spaceghost/databasedotcom-convenience"
  s.summary     = %q{Convenience classes to make using the databasedotcom gem even easier}
  s.description = %q{Convenience classes to make using the databasedotcom gem even easier}

  s.files         = Dir['README.md', 'MIT-LICENSE', 'lib/**/*']
  s.require_paths = ["lib"]
  s.add_dependency('databasedotcom')
  s.add_development_dependency('rspec', '2.6.0')
  s.add_development_dependency('rake', '0.8.6')
end
