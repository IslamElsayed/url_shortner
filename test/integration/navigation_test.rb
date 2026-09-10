require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
  # Not www.example.com. That is ActionDispatch's own test host, so redirecting
  # to it is same-origin and passes even when off-host redirects are broken --
  # which is exactly how the open-redirect failure went unnoticed.
  TARGET = 'https://ruby-lang.org/en/downloads'.freeze

  test "redirects to original URL for valid short_url" do
    record = UrlShortner::ShortenedUrl.create!(url: TARGET)

    get "/url_shortner/#{record.short_url}"

    assert_response :moved_permanently
    assert_redirected_to TARGET
  end

  test "redirects to a host other than the requesting one" do
    record = UrlShortner::ShortenedUrl.create!(url: 'https://rubygems.org/gems/rails')

    get "/url_shortner/#{record.short_url}"

    assert_response :redirect
    assert_equal 'https://rubygems.org/gems/rails', response.headers['Location']
  end

  test "returns 404 for unknown short_url" do
    get "/url_shortner/doesnotexist"

    assert_response :not_found
  end

  test "does not treat a trailing extension as a format" do
    record = UrlShortner::ShortenedUrl.create!(url: TARGET)

    get "/url_shortner/#{record.short_url}.json"

    assert_response :not_found
  end

  test "honours a configured redirect status" do
    record = UrlShortner::ShortenedUrl.create!(url: TARGET)
    original = UrlShortner.redirect_status
    UrlShortner.redirect_status = :found

    get "/url_shortner/#{record.short_url}"

    assert_response :found
  ensure
    UrlShortner.redirect_status = original
  end
end
