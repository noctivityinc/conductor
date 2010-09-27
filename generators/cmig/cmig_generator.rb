class CmigGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'conductor_migration.rb', 'db/migrate', :migration_file_name => "conductor_migration"
    end
  end
end