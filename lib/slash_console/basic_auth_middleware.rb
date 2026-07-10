module SlashConsole
  # Basic authentication for the console in deployed environments.
  #
  # Authentication must happen in the middleware stack, not in
  # ConsoleController: web-console's evaluator endpoints (PUT/POST
  # <mount_point>/repl_sessions/:id) are served directly by
  # WebConsole::Middleware and never reach the router, so a controller
  # filter cannot protect them. This middleware is inserted before
  # WebConsole::Middleware and guards both the console page and the
  # evaluator endpoints with the same credentials.
  class BasicAuthMiddleware
    REALM = "Rails Console"
    CREDENTIALS_MESSAGE = 'Before you can access the console, you must set environment variables called "ADMIN_USERNAME" and "ADMIN_PASSWORD".'

    # The paths the engine serves at its standard mount point: the root
    # (/rails), the console page, and either with a format suffix or
    # trailing slash. Deliberately does not cover other /rails/* paths --
    # unmatched requests cascade past the engine to the host app, which
    # owns paths like /rails/active_storage/*.
    CONSOLE_PATHS = %r{\A/rails(?:/(?:console)?(?:\.[^/]*)?/?)?\z}

    class << self
      # Development and test are the only environments that get an open
      # console. Any deployed environment -- production, staging, preview,
      # or anything else -- must present credentials, because the engine
      # force-enables web-console everywhere and allows all IPs.
      def authentication_required?
        !(Rails.env.development? || Rails.env.test?)
      end

      def credentials_configured?
        ENV["ADMIN_USERNAME"].present? && ENV["ADMIN_PASSWORD"].present?
      end

      def authorized?(username, password)
        ActiveSupport::SecurityUtils.secure_compare(username.to_s, ENV["ADMIN_USERNAME"].to_s) &&
          ActiveSupport::SecurityUtils.secure_compare(password.to_s, ENV["ADMIN_PASSWORD"].to_s)
      end
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) unless self.class.authentication_required? && protects?(env[Rack::PATH_INFO].to_s)

      unless self.class.credentials_configured?
        return [503, {"content-type" => "text/plain"}, [CREDENTIALS_MESSAGE]]
      end

      if valid_credentials?(env)
        @app.call(env)
      else
        unauthorized
      end
    end

    private

    # Destructures rather than splatting: Rack 2 (Rails 7.0 apps) does not
    # validate credential arity in Request#basic?, so a header whose
    # decoded value lacks a colon would otherwise raise instead of 401ing.
    def valid_credentials?(env)
      auth = Rack::Auth::Basic::Request.new(env)
      return false unless auth.provided? && auth.basic?

      username, password = auth.credentials
      self.class.authorized?(username, password)
    end

    def protects?(path)
      CONSOLE_PATHS.match?(path) || evaluator_path?(path)
    end

    def evaluator_path?(path)
      mount_point = WebConsole::Middleware.mount_point
      path == mount_point || path.start_with?("#{mount_point}/")
    end

    def unauthorized
      headers = {
        "content-type" => "text/plain",
        "www-authenticate" => %(Basic realm="#{REALM}")
      }
      [401, headers, ["HTTP Basic: Access denied.\n"]]
    end
  end
end
