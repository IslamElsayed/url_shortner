module UrlShortner
  class ShortenedUrlsController < ApplicationController
    before_action :set_short_url, only: [:show]

    def show
      redirect_to @short_url.url, status: :moved_permanently
    end

    private
      def set_short_url
        @short_url = ShortenedUrl.find_by_short_url(params[:id])
      end
  end
end
