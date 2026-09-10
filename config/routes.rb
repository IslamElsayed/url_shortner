UrlShortner::Engine.routes.draw do
  # Constrained to the url-safe base64 alphabet the codes are drawn from, and
  # format: false so that a code is never mistaken for a filename extension --
  # without it, "/abcd.json" looks up "abcd" and renders as JSON.
  get "/:id",
      to: "shortened_urls#show",
      as: :shortened_url,
      constraints: { id: /[A-Za-z0-9_-]+/ },
      format: false
end
