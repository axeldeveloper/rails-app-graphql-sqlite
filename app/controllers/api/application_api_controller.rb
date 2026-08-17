module Api
  class ApplicationApiController < ActionController::API
    include ActionController::MimeResponds

    include Api::ExceptionHandler

    # Adicionar autenticação se necessário
    # include DeviseTokenAuth::Concerns::SetUserByTokenundefined method `respond_to' for ApplicationApiController:Class

    before_action :set_default_format
    before_action :set_locale

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

    def set_default_format
      request.format = :json
    end

    def set_locale
      I18n.locale = request.headers['Accept-Language']&.scan(/^[a-z]{2}/)&.first || I18n.default_locale
    end
  end
end
