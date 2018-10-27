Rails.application.routes.draw do
  mount UrlShortner::Engine => "/url_shortner"
end
