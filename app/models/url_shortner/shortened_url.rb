module UrlShortner
  class ShortenedUrl < ApplicationRecord
    # validations
    validates :url, uniqueness: true, presence: true
    validates :short_url, uniqueness: true

    # callbacks
    before_create :generate_short_url

    private
      def generate_short_url
        self.short_url = SecureRandom.urlsafe_base64(6, false)
        loop do
          link = self.class.find_by_short_url(self.short_url)
          break unless link
          self.short_url = SecureRandom.urlsafe_base64(6, false)
        end
      end
  end
end
