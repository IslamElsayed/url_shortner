UrlShortner::Engine.routes.draw do
  get '/:id', to: 'shortened_urls#show'
end
