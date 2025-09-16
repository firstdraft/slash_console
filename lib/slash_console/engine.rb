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

    initializer "slash_console.insert_middleware", after: :load_config_initializers do |app|
      app.config.middleware.insert_after ActionDispatch::DebugExceptions, WebConsole::Middleware
    end

    initializer "slash_console.mount_engine" do |app|
      app.routes.prepend do
        mount SlashConsole::Engine => "/rails", :as => :slash_console_engine
      end
    end
  end
end
