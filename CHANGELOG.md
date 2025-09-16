# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/firstdraft/slash_console/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/firstdraft/slash_console/releases/tag/v0.1.0