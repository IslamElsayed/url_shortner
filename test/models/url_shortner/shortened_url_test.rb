require 'test_helper'

module UrlShortner
  class ShortenedUrlTest < ActiveSupport::TestCase
    test "creates a record with a valid URL" do
      record = ShortenedUrl.create(url: 'http://www.example.com')
      assert record.persisted?
    end

    test "auto-generates short_url on create" do
      record = ShortenedUrl.create(url: 'http://www.example.com')
      assert_not_nil record.short_url
      assert record.short_url.length > 0
    end

    test "rejects blank URL" do
      record = ShortenedUrl.new(url: '')
      assert_not record.valid?
      assert_includes record.errors[:url], "can't be blank"
    end

    test "rejects duplicate URL" do
      ShortenedUrl.create(url: 'http://www.example.com')
      duplicate = ShortenedUrl.new(url: 'http://www.example.com')
      assert_not duplicate.valid?
      assert_includes duplicate.errors[:url], "has already been taken"
    end

    test "rejects non-HTTP URL" do
      record = ShortenedUrl.new(url: 'javascript:alert(1)')
      assert_not record.valid?
      assert_includes record.errors[:url], "must be a valid HTTP or HTTPS URL"
    end

    test "rejects plain string as URL" do
      record = ShortenedUrl.new(url: 'not-a-url')
      assert_not record.valid?
    end

    test "accepts HTTPS URL" do
      record = ShortenedUrl.create(url: 'https://www.example.com')
      assert record.persisted?
    end

    test "generates unique short_urls for different URLs" do
      a = ShortenedUrl.create(url: 'http://www.example.com')
      b = ShortenedUrl.create(url: 'http://www.other.com')
      assert_not_equal a.short_url, b.short_url
    end
  end
end
