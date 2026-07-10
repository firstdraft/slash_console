module SlashConsole
  class Engine < ::Rails::Engine
    isolate_namespace SlashConsole

    config.before_initialize do
      Rails.application.config.web_console ||= ActiveSupport::OrderedOptions.new
      Rails.application.config.web_console.development_only = false
      Rails.application.config.web_console.allowed_ips = "0.0.0.0/0"
    end

    initializer "slash_console.load_web_console_extensions", before: :load_config_initializers do
      require "bindex"
      require "web_console/extensions"
    end

    # web-console's own railtie already inserts WebConsole::Middleware
    # (before ActionDispatch::DebugExceptions), so the engine must not
    # insert a second copy. It only adds the authentication middleware,
    # which has to sit in front of WebConsole::Middleware because the
    # evaluator endpoints are served there and never reach the router.
    initializer "slash_console.insert_basic_auth_middleware", after: "web_console.insert_middleware" do |app|
      app.config.middleware.insert_before WebConsole::Middleware, SlashConsole::BasicAuthMiddleware
    end

    initializer "slash_console.mount_engine" do |app|
      app.routes.prepend do
        mount SlashConsole::Engine => "/rails", :as => :slash_console_engine
      end
    end
  end
end
