require "digest"
require "securerandom"

module UrlShortner
  class ShortenedUrl < ApplicationRecord
    URL_FORMAT = %r{\Ahttps?://.+}i.freeze
    SHORT_CODE_FORMAT = /\A[A-Za-z0-9_-]+\z/.freeze
    MAX_GENERATION_ATTEMPTS = 5

    validates :url, presence: true,
                    format: { with: URL_FORMAT, message: "must be a valid HTTP or HTTPS URL" }
    validates :short_url, presence: true, uniqueness: true,
                          format: { with: SHORT_CODE_FORMAT }
    validate :url_must_not_be_taken

    # Generated before validation, not before create, so that the uniqueness
    # and format rules above actually see a value. Run as a create callback it
    # was still nil when they ran, and they passed on every record.
    before_validation :assign_url_digest
    before_validation :assign_short_url, on: :create

    class << self
      # Idempotent: returns the existing record for +url+ if there is one.
      # Retries when a concurrent insert wins either unique index -- a rival
      # taking the same short code, or shortening the same url first.
      def shorten!(url)
        attempts = 0
        begin
          find_by(url_digest: digest_for(url)) || create!(url: url)
        rescue ActiveRecord::RecordNotUnique
          attempts += 1
          raise if attempts > MAX_GENERATION_ATTEMPTS

          retry
        end
      end

      def digest_for(url)
        Digest::SHA256.hexdigest(url.to_s)
      end

      # Bounded, unlike the loop this replaced: if the keyspace is saturated
      # that loop never returned, and the request hung rather than failing.
      def generate_short_code
        MAX_GENERATION_ATTEMPTS.times do
          code = SecureRandom.urlsafe_base64(UrlShortner.short_code_bytes, false)
          return code unless exists?(short_url: code)
        end

        raise GenerationError,
              "no unused short code after #{MAX_GENERATION_ATTEMPTS} attempts; " \
              "raise UrlShortner.short_code_bytes"
      end
    end

    private

    def assign_url_digest
      self.url_digest = self.class.digest_for(url)
    end

    def assign_short_url
      self.short_url ||= self.class.generate_short_code
    end

    # Checked against the indexed digest rather than the url text: no adapter
    # can index a column of unbounded length, so a uniqueness rule on `url`
    # meant a full scan, and had no unique index standing behind it.
    def url_must_not_be_taken
      return if url.blank?

      scope = self.class.where(url_digest: url_digest)
      scope = scope.where.not(id: id) if persisted?
      errors.add(:url, :taken) if scope.exists?
    end
  end
end
