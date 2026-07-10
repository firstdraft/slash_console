require "slash_console/version"
require "slash_console/engine"
require "web-console"

module SlashConsole
  # A fresh binding at the top level, so that console input sees the same
  # +self+ and constant resolution as bin/rails console, rather than the
  # engine's lexical namespace. Each call returns a new binding: local
  # variables persist across evaluations within a console session but do
  # not leak between sessions or into TOPLEVEL_BINDING itself.
  def self.console_binding
    TOPLEVEL_BINDING.eval("binding")
  end
end
