# frozen_string_literal: true

# require_dependency 'repositories/authors_repository'
# Api::V1::AuthorsController is responsible for handling requests related to authors.
# It provides actions to manage and retrieve authors from the API
module Api
  module V1
    # Controller responsible for handling Author-related API endpoints
    class AuthorsController < Api::ApplicationApiController
      before_action :set_author_params, only: %i[show destroy]

      def index
        @authors = AuthorsRepository.all
        render 'api/v1/authors/index', status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      def show
        render 'api/v1/authors/show', status: :ok
      end

      def create
        result = AuthorsRepository.create(author_params)
        if result[:success]
          @author = result[:author]
          render 'api/v1/authors/show', status: :created
        else
          render_details('Validation failed', result[:errors])
        end
      end

      def update
        result = AuthorsRepository.update(params[:id], author_params)
        if result[:success]
          @author = result[:author]
          render 'api/v1/authors/show', status: :ok
        else
          render_details('Validation failed', result[:errors])
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { success: false, error: e.message }, status: :not_found
      end

      def destroy
        AuthorsRepository.destroy(params[:id])
        head :no_content
        # render_success(message: 'Author deleted successfully')
      end

      private

      def author_params
        params.require(:author).permit(:first_name, :last_name, :date_of_birth)
      end

      def set_author_params
        @author = AuthorsRepository.find_with_books(params[:id])
      end
    end
  end
end
