# frozen_string_literal: true

# Api::V1::BooksController is responsible for handling requests related to authors.
# It provides actions to manage and retrieve authors from the API
module Api
  module V1
    class BooksController < Api::ApplicationApiController
      before_action :set_book_params, only: %i[show destroy]

      def index
        @books = Books::ServiceBookList.call
        render 'api/v1/books/index', status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      def show
        render 'api/v1/books/show', status: :ok
      end

      def categories
        # Define a chave do cache com base nos parâmetros da requisição
        cache_key = "categories/#{params[:genre]}"
        # cache_key = 'books_by_category/Terror'

        # Verifica se o cache deve ser renovado
        renew_cache = params[:renew_cache].present?

        # tim = 1.hour
        tim = 1.minute

        @books = Rails.cache.fetch(cache_key, expires_in: tim, force: renew_cache) do
          # Simulação de uma consulta cara ao banco de dados
          # if params[:status].presents
          ::Books::BookByGenreQuery.new(genre: params[:genre]).call.to_a
        end
        puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
        puts @books
        puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'

        render 'api/v1/books/index', status: :ok
      end

      def create
        @book = Books::ServiceBookCreate.call(book_params)
        if @book.is_a?(Book)
          render 'api/v1/books/show', status: :created
        else
          render_details('Validation failed', @book)
        end
      end

      def update
        @book = ::Books::ServiceBookUpdate.new(id: params[:id], params: book_params).call
        if @book.is_a?(Book)
          render 'api/v1/books/show', status: :ok
        else
          render_details('Validation failed', @book)
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { success: false, error: e.message }, status: :not_found
      end

      def destroy
        @book.destroy
        # render json: nil, status: :no_content
        head :no_content
      end

      private

      # def cache_key
      #  'books_by_category/Terror'
      # end

      def book_params
        params.require(:book).permit(:title, :publication_date, :genre, :author_id)
      end

      def set_book_params
        @book = ::Books::ServiceBookOne.new(params[:id]).call
      end
    end
  end
end
