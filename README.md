# SlashConsole

A Rails engine that provides a web-based console interface at `/rails/console`, allowing easy access to a Rails console in both development and production environments.

⚠️ **Security Warning**: This gem provides direct access to the `rails console`. Anyone who accesses it can run arbitrary code on the server: stealing/deleting all your data, planting bugs, sending scam emails, mining cryptocurrency, etc. So, be careful.

- Only use this gem in applications where the security trade-offs are acceptable. Basically, only for toy apps/proofs-of-concept/portfolio projects that contain only sample data. Never use this gem when real user data is at risk.
- For serious apps, SSH into the server and run `rails console` at the command-line. This may require upgrading your hosting from free to paid, but you should be doing that anyway if you have real users.
- Make up a strong, unique `ADMIN_PASSWORD` for each app. There is no rate limiting on the password prompt, so a short or guessable password can be brute-forced.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "slash_console"
```

And then:

```bash
bundle install
```

That's it! Navigate to `/rails/console` in your browser.

## Usage

### Development

In development, no authentication is required. Simply visit `/rails/console`.

### Deployed environments

In every environment other than `development` and `test` — production, staging, previews, anything — authentication is required. Set these environment variables:

```bash
ADMIN_USERNAME="choose_your_own_username"
ADMIN_PASSWORD="choose_your_own_strong_password"
```

Without these environment variables, you'll see an error message explaining what needs to be configured.

If your server runs multiple processes (e.g. Puma workers), console sessions live in the memory of whichever process rendered the page, so evaluating code may intermittently report that your session is no longer available. Run a single process (e.g. `WEB_CONCURRENCY=1`) for a reliable console.

## How It Works

SlashConsole is a lightweight wrapper around [the excellent `web-console` gem](https://github.com/rails/web-console). It:

1. Provides a dedicated route for console access (instead of only on error pages).
2. Renders a full-page console interface, including in apps that enforce a strict nonce-based Content Security Policy.
3. In every environment except development and test, requires basic authentication via a Rack middleware that protects both the console page and web-console's code-evaluation endpoints (`/__web_console/repl_sessions/:id`).
4. Evaluates console input at the top level, so constants resolve the same way as in `bin/rails console`.

Note that SlashConsole configures web-console itself: it activates it in all environments and clears its IP allowlist (authentication replaces it). Any `config.web_console` settings in your app will be overridden.

## Development

After checking out the repo, run `bundle install` to install dependencies.

To install this gem onto your local machine, run `bundle exec rake install`.

### Running Tests

The test suite needs a local PostgreSQL server. Prepare the test database once, then:

```bash
bundle exec rake app:db:test:prepare
bundle exec rake test         # integration + unit tests
bundle exec rake test:system  # browser smoke tests (needs Chrome)
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
