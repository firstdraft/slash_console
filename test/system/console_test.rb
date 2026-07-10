require "application_system_test_case"

# Browser-level proof that the console actually renders and works while
# the dummy app enforces a strict nonce-based Content Security Policy. A
# real browser blocks non-nonced inline styles and scripts, so a blank
# page here (as shipped in 0.1.5) fails these assertions.
class ConsoleTest < ApplicationSystemTestCase
  test "the prompt mounts and evaluates code under a strict CSP" do
    visit "/rails/console"

    assert_selector ".console-prompt-label", text: ">>"

    # The page's inline stylesheet zeroes the body margin; Chrome's default
    # is 8px. If CSP blocked the stylesheet (as in 0.1.5), this fails.
    # (Checks margin-top because web-console's JS sets a bottom margin.)
    assert_equal "0px", evaluate_script("getComputedStyle(document.body).marginTop")

    find("#console").click
    send_keys("6 * 7", :enter)

    assert_selector ".console-message", text: "42"
  end
end
