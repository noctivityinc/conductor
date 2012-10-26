namespace :conductor do
  desc "Rollup raw data for daily processing and reporting"
  task :rollup => :environment do
    p "(conductor) #{Time.now} >> Conductor::RollUp.process"
    Conductor::RollUp.process
  end
end


