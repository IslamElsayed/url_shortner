# UrlShortner

A mountable Rails engine that stores URLs and redirects short codes to them.

Requires Rails 7.0 or newer and Ruby 3.1 or newer.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'url_shortner', github: 'IslamElsayed/url_shortner'
```

And then execute:

```bash
$ bundle
```

Generate the migration and run it:

```bash
$ rails generate url_shortner
$ rails db:migrate
```

Mount the engine in `config/routes.rb`. Mounting at the root gives you the
shortest links, but it will swallow any path that does not match an earlier
route, so mount it last:

```ruby
mount UrlShortner::Engine => "/"
```

## Usage

Shorten a URL:

```ruby
record = UrlShortner.shorten('https://example.com/a/very/long/path')
record.short_url  # => "K3sTv9Qa"
```

`UrlShortner.shorten` is idempotent: shortening the same URL twice returns the
same record rather than issuing a second code. It is also safe to call from
several processes at once — if a competing insert wins, the existing record is
returned instead of raising.

Visiting `/K3sTv9Qa` then redirects to the stored URL.

You can still use the model directly if you want validation errors rather than
an exception:

```ruby
record = UrlShortner::ShortenedUrl.new(url: params[:url])
record.save  # => false, with record.errors, if the URL is invalid or taken
```

## Configuration

```ruby
# config/initializers/url_shortner.rb
UrlShortner.configure do |config|
  # Random bytes behind each code. 6 gives 8 url-safe characters.
  config.short_code_bytes = 6

  # 301 by default. Browsers and proxies cache a 301 indefinitely, which is
  # fast but means a link can never be repointed or retired, because the
  # visitor stops asking. Use :found (302) if you may need to change targets,
  # or want to count clicks.
  config.redirect_status = :moved_permanently
end
```

## What is validated

- The URL must be present and start with `http://` or `https://`, so a
  `javascript:` or `data:` target cannot be stored.
- Each URL is stored once. Uniqueness is enforced by a unique index on a
  SHA-256 digest of the URL rather than on the URL text, because no database
  can index a column of unbounded length.
- Short codes are unique, drawn from the url-safe base64 alphabet, and backed
  by a unique index.

## Development

```bash
$ bundle install
$ bundle exec rake test
```

The test suite runs against the dummy application in `test/dummy`. It sets
`raise_on_open_redirects` explicitly, because that protection is on by default
in any host application and the engine has to work with it.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
