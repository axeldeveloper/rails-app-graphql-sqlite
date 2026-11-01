# frozen_string_literal: true

# Executes GraphQL requests with the current Bearer-authenticated user in context.
class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute
    render json: execute_graphql_query
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  private

  def execute_graphql_query
    GraphqlTestSchema.execute(
      params[:query],
      variables: prepare_variables(params[:variables]),
      context: { current_user: authenticated_user },
      operation_name: params[:operationName]
    )
  end

  def authenticated_user
    Authentication::AccessToken.authenticate_header(request.authorization)
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    return parse_variables(variables_param) if variables_param.is_a?(String)
    return variables_param if variables_param.is_a?(Hash)
    return variables_param.to_unsafe_hash if variables_param.is_a?(ActionController::Parameters)
    return {} if variables_param.nil?

    raise ArgumentError, "Unexpected parameter: #{variables_param}"
  end

  def parse_variables(variables_param)
    return {} if variables_param.blank?

    JSON.parse(variables_param) || {}
  end

  def handle_error_in_development(err)
    logger.error err.message
    logger.error err.backtrace.join("\n")

    render json: { errors: [{ message: err.message, backtrace: err.backtrace }], data: {} },
           status: :internal_server_error
  end
end
