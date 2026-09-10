require 'test_helper'

module UrlShortner
  class ShortenedUrlTest < ActiveSupport::TestCase
    # Deliberately not www.example.com: that is the host ActionDispatch uses in
    # integration tests, so a redirect to it is same-origin and never exercises
    # the off-host path this engine exists to serve.
    TARGET = 'https://ruby-lang.org/en/downloads'.freeze

    test "creates a record with a valid URL" do
      assert ShortenedUrl.create(url: TARGET).persisted?
    end

    test "auto-generates short_url on create" do
      record = ShortenedUrl.create(url: TARGET)
      assert_not_nil record.short_url
      assert_predicate record.short_url.length, :positive?
    end

    test "generated short_url only uses url-safe characters" do
      record = ShortenedUrl.create(url: TARGET)
      assert_match(/\A[A-Za-z0-9_-]+\z/, record.short_url)
    end

    test "rejects blank URL" do
      record = ShortenedUrl.new(url: '')
      assert_not record.valid?
      assert_includes record.errors[:url], "can't be blank"
    end

    test "rejects duplicate URL" do
      ShortenedUrl.create(url: TARGET)
      duplicate = ShortenedUrl.new(url: TARGET)
      assert_not duplicate.valid?
      assert_includes duplicate.errors[:url], "has already been taken"
    end

    test "rejects non-HTTP URL" do
      record = ShortenedUrl.new(url: 'javascript:alert(1)')
      assert_not record.valid?
      assert_includes record.errors[:url], "must be a valid HTTP or HTTPS URL"
    end

    test "rejects plain string as URL" do
      assert_not ShortenedUrl.new(url: 'not-a-url').valid?
    end

    test "accepts HTTPS URL" do
      assert ShortenedUrl.create(url: 'https://www.ruby-lang.org').persisted?
    end

    test "generates unique short_urls for different URLs" do
      a = ShortenedUrl.create(url: 'https://ruby-lang.org/a')
      b = ShortenedUrl.create(url: 'https://ruby-lang.org/b')
      assert_not_equal a.short_url, b.short_url
    end

    # The uniqueness rule used to run before the code was generated, so it was
    # comparing nil on every create and could never reject anything.
    test "short_url uniqueness is validated against the generated value" do
      taken = ShortenedUrl.create(url: 'https://ruby-lang.org/taken')
      clash = ShortenedUrl.new(url: 'https://ruby-lang.org/clash', short_url: taken.short_url)

      assert_not clash.valid?
      assert_includes clash.errors[:short_url], "has already been taken"
    end

    test "a supplied short_url is kept rather than overwritten" do
      record = ShortenedUrl.create(url: TARGET, short_url: 'chosen')
      assert_equal 'chosen', record.short_url
    end

    test "rejects a short_url outside the url-safe alphabet" do
      assert_not ShortenedUrl.new(url: TARGET, short_url: 'has spaces').valid?
    end

    test "stores a digest of the url" do
      record = ShortenedUrl.create(url: TARGET)
      assert_equal Digest::SHA256.hexdigest(TARGET), record.url_digest
    end

    test "shorten! returns the existing record instead of creating a second" do
      first = ShortenedUrl.shorten!(TARGET)

      assert_no_difference -> { ShortenedUrl.count } do
        assert_equal first, ShortenedUrl.shorten!(TARGET)
      end
    end

    test "shorten! creates a record for an unseen url" do
      assert_difference -> { ShortenedUrl.count }, 1 do
        ShortenedUrl.shorten!('https://ruby-lang.org/new')
      end
    end

    test "shorten! raises for an invalid url" do
      assert_raises(ActiveRecord::RecordInvalid) { ShortenedUrl.shorten!('nope') }
    end

    # A rival process inserting the same url between our lookup and our insert
    # used to surface as a bare RecordNotUnique from the database.
    test "shorten! retries when a rival wins the unique index" do
      rival = ShortenedUrl.create!(url: TARGET)
      raised = false

      creator = lambda do |_attrs|
        raised = true
        raise ActiveRecord::RecordNotUnique, 'url_digest'
      end

      lookups = 0
      finder = lambda do |_conditions|
        lookups += 1
        lookups > 1 ? rival : nil
      end

      stubbing(ShortenedUrl, :find_by, finder) do
        stubbing(ShortenedUrl, :create!, creator) do
          assert_equal rival, ShortenedUrl.shorten!(TARGET)
        end
      end

      assert raised, 'expected the first insert to hit the unique index'
    end

    test "shorten! gives up rather than retrying forever" do
      creator = ->(_attrs) { raise ActiveRecord::RecordNotUnique, 'url_digest' }

      stubbing(ShortenedUrl, :find_by, ->(_conditions) { nil }) do
        stubbing(ShortenedUrl, :create!, creator) do
          assert_raises(ActiveRecord::RecordNotUnique) { ShortenedUrl.shorten!(TARGET) }
        end
      end
    end

    test "generate_short_code honours the configured length" do
      original = UrlShortner.short_code_bytes
      UrlShortner.short_code_bytes = 12
      assert_operator ShortenedUrl.generate_short_code.length, :>, 8
    ensure
      UrlShortner.short_code_bytes = original
    end

    test "generate_short_code gives up instead of looping forever" do
      stubbing(ShortenedUrl, :exists?, ->(*) { true }) do
        assert_raises(UrlShortner::GenerationError) { ShortenedUrl.generate_short_code }
      end
    end
  end
end
