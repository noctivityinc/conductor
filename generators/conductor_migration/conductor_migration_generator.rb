class ConductorMigrationGenerator < Rails::Generator::Base
  require 'conductor'
  
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "conductor_migration"
    end
  end
end