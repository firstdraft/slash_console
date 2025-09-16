module SlashConsole
  class Engine < ::Rails::Engine
    isolate_namespace SlashConsole

    initializer "slash_console.mount_engine" do |app|
      app.routes.prepend do
        mount SlashConsole::Engine => "/rails", :as => :slash_console_engine
      end
    end

    initializer "slash_console.configure_web_console" do |app|
      app.config.web_console.development_only = false
    end
  end
end
