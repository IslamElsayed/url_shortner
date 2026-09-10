require 'test_helper'

class UrlShortner::Test < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, UrlShortner
  end

  test "shorten returns a record carrying the short code" do
    record = UrlShortner.shorten('https://ruby-lang.org/en')

    assert_predicate record, :persisted?
    assert_match(/\A[A-Za-z0-9_-]+\z/, record.short_url)
  end

  test "shorten is idempotent for the same url" do
    assert_equal UrlShortner.shorten('https://ruby-lang.org/en'),
                 UrlShortner.shorten('https://ruby-lang.org/en')
  end

  test "configure yields the module" do
    original = UrlShortner.short_code_bytes
    UrlShortner.configure { |config| config.short_code_bytes = 9 }

    assert_equal 9, UrlShortner.short_code_bytes
  ensure
    UrlShortner.short_code_bytes = original
  end
end
