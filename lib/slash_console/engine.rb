module SlashConsole
  class Engine < ::Rails::Engine
    isolate_namespace SlashConsole

    initializer "slash_console.mount_engine" do |app|
      app.routes.prepend do
        mount SlashConsole::Engine => "/rails", :as => :slash_console_engine
      end
    end
  end
end
