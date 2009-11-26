class ActionAuditorMigrationGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
  end
  
  def manifest
    record do |m|
      m.migration_template 'migration.rb', "db/migrate"
    end
  end
  
  def file_name
    "action_auditor_table"
  end
end