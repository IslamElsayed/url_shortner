require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
  test "redirects to original URL for valid short_url" do
    record = UrlShortner::ShortenedUrl.create(url: 'http://www.example.com')
    get "/url_shortner/#{record.short_url}"
    assert_response :moved_permanently
    assert_redirected_to 'http://www.example.com'
  end

  test "returns 404 for unknown short_url" do
    get "/url_shortner/doesnotexist"
    assert_response :not_found
  end
end
