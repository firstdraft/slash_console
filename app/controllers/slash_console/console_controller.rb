module SlashConsole
  class ConsoleController < ApplicationController
    layout false

    skip_before_action :verify_authenticity_token, if: -> { defined?(verify_authenticity_token) }

    # BasicAuthMiddleware is the primary guard: it protects both this page
    # and web-console's evaluator endpoints, but only at the engine's
    # standard /rails mount point. These filters remain as a second layer
    # so the page stays protected if an application mounts the engine at a
    # custom path.
    before_action :ensure_credentials_configured, if: -> { Rails.env.production? }
    before_action :authenticate_user, if: -> { Rails.env.production? }

    def index
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
  end
end
