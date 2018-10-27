# UrlShortner
Simple url shortner gem

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'url_shortner', github: 'IslamElsayed/url_shortner'
```

And then execute:
```bash
$ bundle
```

After you install Shortener run the generator:

$ rails generate url_shortner url_shortner

Then add to your routes:

get '/:id' => "url_shortner/shortened_urls#show"

in order to generate a shortened url:

UrlShortner::ShortenedUrl.create(url: 'http://www.example.com')
it will return an object with attribute short_url to be used

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
