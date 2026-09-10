require "rails/generators"
require "rails/generators/migration"

class UrlShortnerGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path("templates", __dir__)

  # Rails 7.1 moved this setting off ActiveRecord::Base and 8.0 removed the old
  # reader, so calling it there raised NoMethodError and `rails generate
  # url_shortner` could not run at all.
  def self.timestamped_migrations?
    if ActiveRecord.respond_to?(:timestamped_migrations)
      ActiveRecord.timestamped_migrations
    else
      ActiveRecord::Base.timestamped_migrations
    end
  end

  def self.next_migration_number(dirname)
    next_number = current_migration_number(dirname) + 1

    if timestamped_migrations?
      [Time.now.utc.strftime("%Y%m%d%H%M%S"), format("%.14d", next_number)].max
    else
      format("%.3d", next_number)
    end
  end

  def create_migration_file
    migration_template "migration.rb", "db/migrate/create_shortened_urls.rb"
  end
end
