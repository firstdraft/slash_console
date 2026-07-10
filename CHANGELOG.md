# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.7] - 2026-07-10

### Security
- Authentication is now required in every environment except `development`
  and `test`, instead of only `production`. The engine force-enables
  web-console and allows all IPs everywhere, so a `staging`/`preview`
  deployment previously served an unauthenticated console.
- Require web-console >= 4.2.1: versions before 4.1.0 do not put CSP
  nonces on injected assets (silently breaking under a strict CSP), and
  versions before 4.2.1 lack Rack 3 / Rails 7.1 support.
- Enabled `rubygems_mfa_required`, so future gem pushes and yanks require
  a multi-factor-authenticated RubyGems session.

### Fixed
- A malformed Basic Authorization header (credentials without a colon)
  now gets a 401 on Rack 2 instead of raising.
- Stored console sessions are capped at 50 per process. web-console's
  session store is never evicted otherwise, so each console page load
  pinned a binding in memory until process restart.

### Removed
- Deleted the engine's unused application layout, which referenced a
  stylesheet that does not ship with the gem, and a no-op CSRF skip in
  the console controller (the console page is GET-only).

## [0.1.6] - 2026-07-10

### Security
- Production Basic authentication moved from the controller into a Rack
  middleware inserted in front of `WebConsole::Middleware`, so it now covers
  web-console's evaluator endpoints (`/__web_console/repl_sessions/:id`) as
  well as the console page. Previously a console session ID acted as an
  unauthenticated bearer token for code execution until process restart.

### Fixed
- The console renders under a strict nonce-based Content Security Policy.
  The page stylesheet carries Rails' per-request nonce, and requesting the
  nonce during rendering makes it available to web-console's injected
  scripts even when the app hoists the CSP middleware above web-console
  (previously such apps got a nonempty header nonce but `nonce=""` scripts,
  i.e. a blank console).
- Console input evaluates in a fresh top-level binding, so constants
  resolve the same way as in `bin/rails console` instead of inside the
  engine's namespace (`ApplicationController` no longer resolves to
  `SlashConsole::ApplicationController`, and app constants no longer need a
  leading `::`). Local variables persist within a console session but not
  across sessions.
- Removed the duplicate `WebConsole::Middleware` the engine inserted
  alongside the copy web-console's own railtie already adds.

## [0.1.5] - 2025-09-15

### Fixed
- Load web-console extensions explicitly to fix blank page in production
- Add full-page CSS for console element to ensure proper display
- Use modern viewport units (100svh) for better mobile compatibility

## [0.1.4] - 2025-09-15

### Fixed
- Allow console access from all IPs in production (with authentication)
- Fix blank page issue on cloud platforms like Render

### Changed
- Add security note about IP allowlist in README

## [0.1.3] - 2025-09-15

### Changed
- Add proper GitHub repository metadata links
- Add bug tracker and documentation URIs
- Specify minimum Ruby version (>= 3.0)
- Include CHANGELOG.md in gem files

## [0.1.2] - 2025-09-15

### Fixed
- Configure web-console earlier in boot process using before_initialize
- Properly initialize web_console config to prevent production deployment errors

## [0.1.1] - 2025-09-15

### Fixed
- Configure web-console to allow production mode deployment
- Prevent "Web Console is activated in production" error on Render and similar platforms

## [0.1.0] - 2025-09-15

### Added
- Initial release
- Auto-mounting at `/rails/console`
- Production authentication via environment variables
- Full-page console interface
- Development mode with no authentication required
- Standard Ruby style guide compliance

[Unreleased]: https://github.com/firstdraft/slash_console/compare/v0.1.7...HEAD
[0.1.7]: https://github.com/firstdraft/slash_console/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/firstdraft/slash_console/compare/v0.1.0...v0.1.6
[0.1.0]: https://github.com/firstdraft/slash_console/releases/tag/v0.1.0
