require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  USERNAME = "admin"
  PASSWORD = "sekrit"

  EVALUATOR_PATH = "#{WebConsole::Middleware.mount_point}/repl_sessions/nonexistent"

  setup do
    @original_username = ENV["ADMIN_USERNAME"]
    @original_password = ENV["ADMIN_PASSWORD"]
    ENV["ADMIN_USERNAME"] = USERNAME
    ENV["ADMIN_PASSWORD"] = PASSWORD
  end

  teardown do
    ENV["ADMIN_USERNAME"] = @original_username
    ENV["ADMIN_PASSWORD"] = @original_password
  end

  def in_env(name, &block)
    Rails.stub(:env, ActiveSupport::EnvironmentInquirer.new(name), &block)
  end

  def in_production(&block)
    in_env("production", &block)
  end

  def credentials(username, password)
    {"Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password)}
  end

  test "anonymous console page request is refused in production" do
    in_production do
      get "/rails/console"
    end

    assert_response :unauthorized
    assert_match(/Basic realm=/, response.headers["WWW-Authenticate"])
  end

  test "wrong credentials are refused on the console page in production" do
    in_production do
      get "/rails/console", headers: credentials(USERNAME, "wrong")
    end

    assert_response :unauthorized
  end

  test "a malformed authorization header is refused, not an error" do
    in_production do
      get "/rails/console", headers: {"Authorization" => "Basic #{["nocolon"].pack("m0")}"}
    end

    assert_response :unauthorized
  end

  test "anonymous evaluator request is refused in production" do
    in_production do
      put EVALUATOR_PATH, params: {input: "1 + 1"}, xhr: true
    end

    assert_response :unauthorized
    assert_match(/Basic realm=/, response.headers["WWW-Authenticate"])
  end

  test "wrong credentials are refused on the evaluator in production" do
    in_production do
      put EVALUATOR_PATH, params: {input: "1 + 1"}, xhr: true,
        headers: credentials("intruder", PASSWORD)
    end

    assert_response :unauthorized
  end

  test "valid credentials load the console page in production" do
    in_production do
      get "/rails/console", headers: credentials(USERNAME, PASSWORD)
    end

    assert_response :success
    assert_includes response.body, "id=\"console\""
    assert response.headers["x-web-console-session-id"].present?
  end

  test "valid credentials reach normal 404 handling for unknown evaluator sessions" do
    in_production do
      put EVALUATOR_PATH, params: {input: "1 + 1"}, xhr: true,
        headers: credentials(USERNAME, PASSWORD)
    end

    assert_response :not_found
    assert_includes response.parsed_body.fetch("output"), "no longer available"
  end

  test "an authenticated console session can evaluate code in production" do
    in_production do
      get "/rails/console", headers: credentials(USERNAME, PASSWORD)
      session_id = response.headers.fetch("x-web-console-session-id")

      put "#{WebConsole::Middleware.mount_point}/repl_sessions/#{session_id}",
        params: {input: "6 * 7"}, xhr: true, headers: credentials(USERNAME, PASSWORD)
    end

    assert_response :success
    assert_includes response.parsed_body.fetch("output"), "42"
  end

  test "missing credential configuration disables the console page in production" do
    ENV["ADMIN_USERNAME"] = nil

    in_production do
      get "/rails/console"
    end

    assert_response :service_unavailable
    assert_includes response.body, "ADMIN_USERNAME"
  end

  test "missing credential configuration disables the evaluator in production" do
    ENV["ADMIN_PASSWORD"] = nil

    in_production do
      put EVALUATOR_PATH, params: {input: "1 + 1"}, xhr: true
    end

    assert_response :service_unavailable
    assert_includes response.body, "ADMIN_PASSWORD"
  end

  test "custom deployed environments like staging also require authentication" do
    in_env("staging") do
      get "/rails/console"
    end

    assert_response :unauthorized

    in_env("staging") do
      put EVALUATOR_PATH, params: {input: "1 + 1"}, xhr: true
    end

    assert_response :unauthorized

    in_env("staging") do
      get "/rails/console", headers: credentials(USERNAME, PASSWORD)
    end

    assert_response :success
  end

  test "the controller still protects custom mount points in deployed environments" do
    in_production do
      get "/slash_console/console"
    end

    assert_response :unauthorized

    in_env("staging") do
      get "/slash_console/console"
    end

    assert_response :unauthorized

    in_production do
      get "/slash_console/console", headers: credentials(USERNAME, PASSWORD)
    end

    assert_response :success
  end

  test "no authentication is required in development" do
    in_env("development") do
      get "/rails/console"
    end

    assert_response :success
  end

  test "no authentication is required in the test environment" do
    get "/rails/console"

    assert_response :success
  end
end
