# frozen_string_literal: true

module Api
  module ExceptionHandler
    extend ActiveSupport::Concern

    included do
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
      rescue_from StandardError, with: :internal_server_error if Rails.env.production?

      private

      def not_found
        render_error('Recurso não encontrado', :not_found)
      end

      def parameter_missing(exception)
        Rails.logger.warn 'ExceptionHandler está com erro no parametro missing'
        Rails.logger.warn exception.message
        render_error(exception.message, :bad_request)
      end

      def record_invalid(exception)
        render_error(exception.record.errors.full_messages, :unprocessable_entity)
      end

      def internal_server_error(_exception)
        render_error('Erro interno do servidor 45', :internal_server_error)
      end

      def render_error(message, status = :not_found)
        render json: {
          success: false,
          error: message
        }, status: status
      end

      def render_details(message, details, status = :unprocessable_entity)
        error_response = {
          success: false,
          error: message,
          details: nil
        }
        error_response[:details] = details.is_a?(Array) ? details : [details]
        render json: error_response, status: status
      end
    end
  end
end
