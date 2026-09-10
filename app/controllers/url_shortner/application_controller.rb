module UrlShortner
  class ApplicationController < ActionController::Base
    # Every action here is a GET redirect, so there is no form to protect.
    # Leaving forgery protection on would also require session middleware that
    # an api_only host app does not load.
    skip_forgery_protection
  end
end
