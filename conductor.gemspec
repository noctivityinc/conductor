# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{conductor}
  s.version = "0.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Noctivity"]
  s.date = %q{2010-10-03}
  s.description = %q{Conductor is the bastard child of a/b testing and personalization.  It throws everything you know about creating a web site our the window and lets you just "try stuff" without ever having to worry about not maximing your site's "purpose."  Have a new landing page?  Just throw it to the conductor.  Want to try different price points - conductor.  Different form designs?  Conductor.  Conductor will rotate all alternatives through the mix and eventually settle on the top performing of all, without you having to do anything other than just creating.  Think "intelligent A/B testing" on steriods.}
  s.email = %q{jlippiner@noctivity.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "generators/conductor/conductor_generator.rb",
     "generators/conductor/templates/conductor.css",
     "generators/conductor/templates/conductor.rake",
     "generators/conductor/templates/migration.rb",
     "init.rb",
     "lib/conductor.rb",
     "lib/conductor/controller/dashboard.rb",
     "lib/conductor/experiment.rb",
     "lib/conductor/experiment/daily.rb",
     "lib/conductor/experiment/history.rb",
     "lib/conductor/experiment/raw.rb",
     "lib/conductor/experiment/weight.rb",
     "lib/conductor/helpers/dashboard_helper.rb",
     "lib/conductor/roll_up.rb",
     "lib/conductor/views/dashboard/_current_weights.html.haml",
     "lib/conductor/views/dashboard/_daily_stats.html.haml",
     "lib/conductor/views/dashboard/_top_nav.html.haml",
     "lib/conductor/views/dashboard/_weight_history.html.haml",
     "lib/conductor/views/dashboard/index.html.haml",
     "lib/conductor/weights.rb",
     "rails/init.rb"
  ]
  s.homepage = %q{http://github.com/noctivityinc/conductor}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{conductor}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{lets you just try things while always maximizing towards a goal (e.g. purchase, signups, etc)}
  s.test_files = [
    "test/db/schema.rb",
     "test/test_conductor.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<googlecharts>, [">= 0"])
      s.add_runtime_dependency(%q<haml>, [">= 0"])
    else
      s.add_dependency(%q<googlecharts>, [">= 0"])
      s.add_dependency(%q<haml>, [">= 0"])
    end
  else
    s.add_dependency(%q<googlecharts>, [">= 0"])
    s.add_dependency(%q<haml>, [">= 0"])
  end
end

