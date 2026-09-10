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
  s.description = "A mountable Rails engine that stores URLs and redirects short codes to them."
  s.homepage    = "https://github.com/IslamElsayed/url_shortner"
  s.metadata    = {
    "source_code_uri" => "https://github.com/IslamElsayed/url_shortner",
    "rubygems_mfa_required" => "true"
  }
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.required_ruby_version = ">= 3.1"

  # 7.0 is the floor because the engine passes allow_other_host: to
  # redirect_to, which does not exist before it -- and without it the engine
  # cannot redirect off-host at all, which is its only job.
  s.add_dependency "rails", ">= 7.0"

  s.add_development_dependency "sqlite3", "~> 2.1"
end
