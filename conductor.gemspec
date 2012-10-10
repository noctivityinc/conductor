$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "conductor/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "conductor"
  s.version     = Conductor::VERSION
  s.authors = ["Noctivity"]
  s.date = '2012-10-10'
  s.description = "Conductor is the bastard child of a/b testing and personalization.  It throws everything you know about creating a web site our the window and lets you just \"try stuff\" without ever having to worry about not maximing your site's \"purpose.\"  Have a new landing page?  Just throw it to the conductor.  Want to try different price points - conductor.  Different form designs?  Conductor.  Conductor will rotate all alternatives through the mix and eventually settle on the top performing of all, without you having to do anything other than just creating.  Think ""intelligent A/B testing"" on steriods."
  s.email = 'jlippiner@noctivity.com'
  s.summary = "lets you just try things while always maximizing towards a goal (e.g. purchase, signups, etc)"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "googlecharts"
  s.add_dependency "haml"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "guard-spork"
end
