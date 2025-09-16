# SlashConsole

A Rails engine that provides a web-based console interface at `/rails/console`, allowing easy access to a Rails console in both development and production environments.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "slash_console"
```

And then execute:

```bash
bundle install
```

That's it! Navigate to `/rails/console` in your browser.

## Usage

### Development

In development, no authentication is required. Simply visit:

```
http://localhost:3000/rails/console
```

### Production

For production use, authentication is **required**. Set these environment variables:

```bash
ADMIN_USERNAME="choose_your_own_username"
ADMIN_PASSWORD="choose_your_own_strong_password"
```

Without these environment variables, you'll see an error message explaining what needs to be configured.

⚠️ **Security Warning**: This gem provides direct access to your Rails console. In production:

- Only use for applications where the security trade-offs are acceptable. Basically, only for toy apps; never where real user data is at risk. For serious apps, SSH into the server and run `rails console` at the command-line.
- Make up a strong, unique `ADMIN_PASSWORD` for each app.

## How It Works

SlashConsole is a lightweight wrapper around the excellent `web-console` gem. It:

1. Provides a dedicated route for console access (instead of only on error pages).
2. Renders a full-page console interface.
3. Uses basic authentication when in production.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

### Running Tests

```bash
bundle exec rake test
```

### Linting

This project uses [Standard](https://github.com/standardrb/standard) for Ruby style:

```bash
bundle exec standardrb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/firstdraft/slash_console.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make your changes
4. Run tests and linting
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

This gem is built on top of the [web-console](https://github.com/rails/web-console) gem. Many thanks to the Rails team and web-console contributors for their excellent work.
