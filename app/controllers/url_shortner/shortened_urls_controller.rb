module UrlShortner
  class ShortenedUrlsController < ApplicationController
    before_action :set_short_url, only: [:show]

    def show
      return head :not_found if @short_url.nil?

      # allow_other_host is not optional here. Sending a visitor to another
      # origin is the entire purpose of the engine, and Rails refuses to do it
      # by default from 7.0 onward -- without this the action raises
      # UnsafeRedirectError and the host app returns 500.
      redirect_to @short_url.url,
                  status: UrlShortner.redirect_status,
                  allow_other_host: true
    end

    private

    def set_short_url
      @short_url = ShortenedUrl.find_by(short_url: params[:id])
    end
  end
end
