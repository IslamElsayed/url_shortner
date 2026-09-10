require 'test_helper'
require 'rails/generators'
require 'generators/url_shortner/url_shortner_generator'

# Rails 7.1 moved timestamped_migrations off ActiveRecord::Base; calling the old
# reader on 8.0 raised NoMethodError, so `rails generate url_shortner` could not
# run at all on a current Rails.
class UrlShortnerGeneratorTest < ActiveSupport::TestCase
  test "next_migration_number does not raise on a modern Rails" do
    Dir.mktmpdir do |dir|
      assert_nothing_raised { UrlShortnerGenerator.next_migration_number(dir) }
    end
  end

  test "next_migration_number is a usable migration timestamp" do
    Dir.mktmpdir do |dir|
      assert_match(/\A\d{14}\z/, UrlShortnerGenerator.next_migration_number(dir).to_s)
    end
  end
end
