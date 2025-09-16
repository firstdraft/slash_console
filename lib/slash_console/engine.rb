module SlashConsole
  class Engine < ::Rails::Engine
    isolate_namespace SlashConsole

    config.before_initialize do
      Rails.application.config.web_console ||= ActiveSupport::OrderedOptions.new
      Rails.application.config.web_console.development_only = false
    end

    initializer "slash_console.mount_engine" do |app|
      app.routes.prepend do
        mount SlashConsole::Engine => "/rails", :as => :slash_console_engine
      end
    end
  end
end
