SlashConsole::Engine.routes.draw do
  get "console" => "console#index", as: :console
  root to: "console#index"
end
