require "test_helper"

class MiddlewareStackTest < ActiveSupport::TestCase
  def stack
    Rails.application.middleware.middlewares
  end

  test "WebConsole::Middleware appears exactly once" do
    assert_equal 1, stack.count(WebConsole::Middleware)
  end

  test "authentication runs before WebConsole::Middleware" do
    auth_index = stack.index(SlashConsole::BasicAuthMiddleware)
    web_console_index = stack.index(WebConsole::Middleware)

    assert auth_index, "SlashConsole::BasicAuthMiddleware is missing from the stack"
    assert_equal web_console_index - 1, auth_index
  end

  test "the protected path pattern covers every path the engine serves" do
    pattern = SlashConsole::BasicAuthMiddleware::CONSOLE_PATHS

    ["/rails", "/rails/", "/rails/console", "/rails/console/",
      "/rails/console.html", "/rails/console.json", "/rails/.json"].each do |path|
      assert_match pattern, path
    end
  end

  test "the protected path pattern leaves cascaded host app paths alone" do
    pattern = SlashConsole::BasicAuthMiddleware::CONSOLE_PATHS

    ["/rails/active_storage/blobs/redirect/abc/photo.jpg",
      "/rails/conductor/action_mailbox/inbound_emails",
      "/railsy", "/", "/other"].each do |path|
      refute_match pattern, path
    end
  end
end
