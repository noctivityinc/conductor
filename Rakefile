require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "conductor"
    gem.summary = %Q{lets you just try things while always maximizing towards a goal (e.g. purchase, signups, etc)}
    gem.description = %Q{Conductor is the bastard child of a/b testing and personalization.  It throws everything you know about creating a web site our the window and lets you just "try stuff" without ever having to worry about not maximing your site's "purpose."  Have a new landing page?  Just throw it to the conductor.  Want to try different price points - conductor.  Different form designs?  Conductor.  Conductor will rotate all alternatives through the mix and eventually settle on the top performing of all, without you having to do anything other than just creating.  Think "intelligent A/B testing" on steriods.}
    gem.email = "jlippiner@noctivity.com"
    gem.homepage = "http://github.com/noctivityinc/conductor"
    gem.authors = ["Noctivity"]
    gem.rubyforge_project = "conductor"
    gem.files =  FileList["[A-Z]*", "{generators,lib,tasks}/**/*", "init.rb"]
    gem.add_dependency 'googlecharts'
    gem.add_dependency 'haml'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "conductor #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

