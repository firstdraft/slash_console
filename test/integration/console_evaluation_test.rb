require "test_helper"

class ConsoleEvaluationTest < ActionDispatch::IntegrationTest
  def start_console_session
    get "/rails/console"
    assert_response :success
    response.headers.fetch("x-web-console-session-id")
  end

  def evaluate(session_id, input)
    put "#{WebConsole::Middleware.mount_point}/repl_sessions/#{session_id}",
      params: {input: input}, xhr: true
    assert_response :success
    response.parsed_body.fetch("output")
  end

  test "evaluates at the top level, not inside the engine's namespace" do
    session_id = start_console_session

    assert_equal "=> \"ApplicationController\"\n",
      evaluate(session_id, "ApplicationController.name")
    assert_equal "=> \"main\"\n", evaluate(session_id, "to_s")
  end

  test "reaches Rails-loaded constants like rails console does" do
    session_id = start_console_session

    assert_equal "=> \"test\"\n", evaluate(session_id, "Rails.env")
    assert_equal "=> \"Dummy::Application\"\n",
      evaluate(session_id, "Rails.application.class.name")
  end

  test "local variables persist within a session" do
    session_id = start_console_session

    evaluate(session_id, "x = 41")
    assert_equal "=> 42\n", evaluate(session_id, "x + 1")
  end

  test "local variables do not leak between sessions" do
    first_session = start_console_session
    evaluate(first_session, "leaky = true")

    second_session = start_console_session
    assert_match(/NameError/, evaluate(second_session, "leaky"))
  end

  test "stored sessions are capped so page loads cannot pin memory forever" do
    max = SlashConsole::ConsoleController::MAX_STORED_SESSIONS
    oldest_session = start_console_session

    (max + 1).times { start_console_session }
    newest_session = start_console_session

    assert_operator WebConsole::Session.inmemory_storage.size, :<=, max
    assert_nil WebConsole::Session.find(oldest_session)
    assert_equal "=> 42\n", evaluate(newest_session, "6 * 7")
  end
end
