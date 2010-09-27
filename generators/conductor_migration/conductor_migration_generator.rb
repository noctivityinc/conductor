class ConductorMigrationGenerator < Rails::Generator::Base
  require 'conductor'
  
  def manifest
    record do |m|
      m.migration_template 'conductor_migration.rb', 'db/migrate', 
        :assigns => {:version => Conductor.MAJOR_VERSION.gsub(".", "")}
    end
  end
end