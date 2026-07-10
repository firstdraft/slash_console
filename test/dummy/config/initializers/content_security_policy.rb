# A strict, enforced, nonce-based Content Security Policy with no
# unsafe-inline, mirroring the apps this gem must work inside.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.object_src :none
    policy.script_src :self
    policy.style_src :self
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Host apps may hoist the CSP middleware above ShowExceptions so that
  # error responses carry the policy too. That places it above
  # WebConsole::Middleware, meaning the response header's nonce is only
  # generated AFTER web-console has already injected its scripts -- the
  # exact topology in which 0.1.5 produced nonce="" scripts and a blank
  # console. Keep this so the test suite covers that arrangement.
  config.middleware.move_before ActionDispatch::ShowExceptions, ActionDispatch::ContentSecurityPolicy::Middleware
end
