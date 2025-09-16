module SlashConsole
  class ConsoleController < ApplicationController
    layout false

    skip_before_action :verify_authenticity_token, if: -> { defined?(verify_authenticity_token) }

    before_action :ensure_credentials_configured, if: -> { Rails.env.production? }
    before_action :authenticate_user, if: -> { Rails.env.production? }

    def index
      console
      render :index
    end

    private

    def ensure_credentials_configured
      if ENV["ADMIN_USERNAME"].blank? || ENV["ADMIN_PASSWORD"].blank?
        render plain: 'Before you can access the console, you must set environment variables called "ADMIN_USERNAME" and "ADMIN_PASSWORD".',
               status: :service_unavailable
      end
    end

    def authenticate_user
      authenticate_or_request_with_http_basic("Rails Console") do |username, password|
        ActiveSupport::SecurityUtils.secure_compare(username, ENV["ADMIN_USERNAME"]) &&
          ActiveSupport::SecurityUtils.secure_compare(password, ENV["ADMIN_PASSWORD"])
      end
    end
  end
end