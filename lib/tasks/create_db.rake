SCHEMA_NAMES = %w(postrello)
namespace :db do
  task :create do
    config = Rails.configuration.database_configuration[Rails.env].merge!({'schema_search_path' => 'public'})
    ActiveRecord::Base.establish_connection(config)
    SCHEMA_NAMES.each do |schema|
      if !ActiveRecord::Base.connection.schema_exists?(schema)
        ActiveRecord::Base.connection.execute("CREATE SCHEMA #{schema}")
      end
    end
  end
end
