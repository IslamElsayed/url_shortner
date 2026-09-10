# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require "rails/test_help"
require "tmpdir"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new


# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

# Minitest 6 dropped minitest/mock, so Object#stub is gone. This replaces the
# one use we have of it: swap a class method for the duration of a block and
# put the original back, whether it was defined here or inherited.
module MethodStubbing
  def stubbing(target, name, replacement)
    singleton = target.singleton_class
    original = singleton.method_defined?(name, false) ? singleton.instance_method(name) : nil

    singleton.send(:define_method, name) { |*args, **kwargs, &block| replacement.call(*args, **kwargs, &block) }
    yield
  ensure
    singleton.send(:remove_method, name)
    singleton.send(:define_method, name, original) if original
  end
end

ActiveSupport::TestCase.include(MethodStubbing)
