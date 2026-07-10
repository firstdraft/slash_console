require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "the console uses the response Content Security Policy nonce" do
    get "/rails/console"

    assert_response :success
    nonce = response.headers.fetch("Content-Security-Policy")[/nonce-([^']+)/, 1]
    assert nonce.present?
    assert_includes response.body, %(<style nonce="#{nonce}">)

    scripts = response.body.scan(/<script\b[^>]*>/)
    assert_operator scripts.length, :>=, 3
    scripts.each { |script| assert_includes script, %(nonce="#{nonce}") }
    refute_includes response.body, %(nonce="")
  end
end
