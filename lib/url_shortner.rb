require "active_support/core_ext/module/attribute_accessors"
require "url_shortner/engine"

module UrlShortner
  class Error < StandardError; end

  # Raised when a short code cannot be generated without colliding.
  class GenerationError < Error; end

  # Random bytes behind each short code. Six bytes is eight url-safe base64
  # characters, or about 2.8e14 codes.
  mattr_accessor :short_code_bytes, default: 6

  # Status used to send a visitor on to the target.
  #
  # 301 is cached by browsers and proxies indefinitely, which is fast but means
  # a link can never be repointed or retired: the visitor stops asking us. Set
  # this to :found to keep that option open.
  mattr_accessor :redirect_status, default: :moved_permanently

  # The short code for +url+, creating one only if it has not been shortened
  # before. Safe to call concurrently for the same url.
  def self.shorten(url)
    ShortenedUrl.shorten!(url)
  end

  def self.configure
    yield self
  end
end
