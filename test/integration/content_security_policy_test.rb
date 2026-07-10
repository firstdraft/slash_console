require "test_helper"

# The dummy app enforces a strict, nonce-based Content Security Policy
# (see test/dummy/config/initializers/content_security_policy.rb) with no
# unsafe-inline. These tests pin the behavior that broke in 0.1.5: the
# console page rendered blank because its inline style carried no nonce
# and web-console's injected scripts carried nonce="".
class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test "the console uses the response Content Security Policy nonce" do
    get "/rails/console"

    assert_response :success
    csp = response.headers.fetch("Content-Security-Policy")
    nonce = csp[/nonce-([^']+)/, 1]
    assert nonce.present?, "expected the CSP header to contain a nonce: #{csp}"
    assert_includes csp, "script-src 'self' 'nonce-#{nonce}'"
    assert_includes csp, "style-src 'self' 'nonce-#{nonce}'"

    assert_includes response.body, %(<style nonce="#{nonce}">)

    scripts = response.body.scan(/<script\b[^>]*>/)
    assert_operator scripts.length, :>=, 3,
      "expected web-console to inject its scripts into the page"
    scripts.each { |script| assert_includes script, %(nonce="#{nonce}") }

    refute_includes response.body, %(nonce="")
  end

  test "the strict policy is not weakened for the console" do
    get "/rails/console"

    csp = response.headers.fetch("Content-Security-Policy")
    refute_includes csp, "unsafe-inline"
    refute_includes csp, "unsafe-eval"
  end
end
