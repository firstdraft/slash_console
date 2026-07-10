module SlashConsole
  class ConsoleController < ApplicationController
    layout false

    # web-console stores every console session (and the binding it holds)
    # in an in-memory hash that is never evicted, so each page load would
    # otherwise pin memory until the process restarts. Old sessions are
    # dropped once this many accumulate; an evicted session's tab shows
    # web-console's normal "session is no longer available" message.
    MAX_STORED_SESSIONS = 50

    # BasicAuthMiddleware is the primary guard: it protects both this page
    # and web-console's evaluator endpoints, but only at the engine's
    # standard /rails mount point. These filters remain as a second layer
    # so the page stays protected if an application mounts the engine at a
    # custom path.
    before_action :ensure_credentials_configured, if: -> { BasicAuthMiddleware.authentication_required? }
    before_action :authenticate_user, if: -> { BasicAuthMiddleware.authentication_required? }

    def index
      prune_console_sessions
      console(SlashConsole.console_binding)
      render :index
    end

    private

    def ensure_credentials_configured
      unless BasicAuthMiddleware.credentials_configured?
        render plain: BasicAuthMiddleware::CREDENTIALS_MESSAGE, status: :service_unavailable
      end
    end

    def authenticate_user
      authenticate_or_request_with_http_basic(BasicAuthMiddleware::REALM) do |username, password|
        BasicAuthMiddleware.authorized?(username, password)
      end
    end

    def prune_console_sessions
      storage = WebConsole::Session.inmemory_storage
      storage.shift while storage.size >= MAX_STORED_SESSIONS
    end
  end
end
