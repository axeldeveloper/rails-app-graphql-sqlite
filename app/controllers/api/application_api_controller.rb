# frozen_string_literal: true

module Api
  # Shared API behavior and Bearer authentication for protected writes.
  class ApplicationApiController < ActionController::API
    include ActionController::Cookies
    include ActionController::MimeResponds

    include Api::ExceptionHandler

    before_action :set_default_format
    before_action :set_locale
    before_action :authenticate_user!, if: :protected_write_request?

    attr_reader :current_user

    protected

    def render_success(data, status = :ok)
      render json: {
        success: true,
        data: data
      }, status: status
    end

    def pagination_meta(object)
      {
        current_page: object.current_page,
        total_items: object.total_count,
        total_pages: object.total_pages,
        per_page: object.limit_value
      }
    end

    private

    def protected_write_request?
      controller_path.in?(%w[api/v1/books api/v1/authors]) &&
        request.method.in?(%w[POST PUT PATCH DELETE])
    end

    def authenticate_user!
      @current_user = Authentication::AccessToken.authenticate_header(request.authorization)
      return if @current_user

      render json: { error: 'Unauthorized', message: 'Authentication required' }, status: :unauthorized
    end

    def set_default_format
      request.format = :json
    end

    def set_locale
      I18n.locale = request.headers['Accept-Language']&.scan(/^[a-z]{2}/)&.first || I18n.default_locale
    end
  end
end
