require 'conductor'

namespace :conductor do
  desc "Rolls-up raw data into the daily conductor model for use in weights"
  task :rollup do
    Conductor::Rollup.process
  end
end
