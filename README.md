# GemsBond

GemsBond inspects your Gemfile and calculates a score for each gem depending on its activity and popularity.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gems_bond'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install gems_bond

## Usage

### Spy one

Get information about a given gem. The result is display in the terminal.

```bash
bundle exec rake gems_bond:spy:one rails
```

This will output:

```
-------- RAILS INFO --------

Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity. It encourages beautiful code by favoring convention over configuration.

- url: https://github.com/rails/rails/tree/v6.1.3
- version: 5.2.0 (27 behind 6.1.3)
- counts: 270 222 380 downloads | 19 185 forks | 47 738 stars | 375 contributors
- activity: 21 days since last version | 0 days since last commit
```

You can spy any gem by its name, even if it is not in your project dependencies.

### Spy all

Get information and scoring for all of the current project gems.

First, you need to get a GithHub token since the gem fetches data from the GitHub API.

When logged in on GitHub, go in https://github.com/settings/tokens and generate a new token.

A readonly token is enough, you can leave all checkbox unchecked.

Add the token in your config:

```ruby
# config/initializers/gems_bond.rb

GemsBond.configure do |config|
  config.github_token = 'my_github_readonly_token'
end
```

Then run the task:

```bash
bundle exec rake gems_bond:spy:all
```

You can provide the token at this moment if it is not set in configuration or if you want to override it:

```bash
bundle exec rake gems_bond:spy:all GITHUB_TOKEN=my_github_readonly_token
```

The output can then be read in `gems_bond/spy.csv` and `gems_bond/spy.html`.

![example](public/example.png)

## Development

After checking out the repo, run `bin/setup` to install dependencies.

Add a github token in the `.env.test` file (`GITHUB_TOKEN=<token>`) then run `rspec`, or run `rspec --tag ~@api` to skip tests calling RubyGems and GitHub APIs.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gems_bond.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
