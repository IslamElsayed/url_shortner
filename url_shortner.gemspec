$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "url_shortner/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "url_shortner"
  s.version     = UrlShortner::VERSION
  s.authors     = ["Islam Elsayed"]
  s.email       = ["islam.elsayed.mohammed@gmail.com"]
  s.summary     = "Url shortening implementation."
  s.description = "Url shortening implementation."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.1"

  s.add_development_dependency "sqlite3"
end
