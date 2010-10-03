# encoding: utf-8

class ConductorGenerator < Rails::Generator::Base

  def initialize(*runtime_args)
    super
  end

  def manifest
    record do |m|
      m.directory File.join('lib', 'tasks')
      m.template 'conductor.rake',   File.join('lib', 'tasks', 'conductor.rake')

      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "conductor_migration"

      m.directory File.join('public', 'stylesheets')
      m.template 'conductor.css',   File.join('public', 'stylesheets', 'conductor.css')
    end
  end

  protected

  def banner
    %{Usage: #{$0} #{spec.name}\nCopies conductor.rake to lib/tasks.  Copies migration file to db/migrate.  Copies conductor.css to public/stylesheets/}
  end

end