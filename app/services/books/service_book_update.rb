# frozen_string_literal: true

module Books
  # Service object responsible for updating books in the system
  class ServiceBookUpdate < ApplicationService
    def initialize(id:, params:)
      super()
      @id = id
      @book_param = params
    end

    def call
      update_book
    end

    private

    def update_book
      result = BooksRepository.update(@id, @book_param)
      if result[:success]
        notify_user_creation(result[:book])
        result[:book]
      else
        Rails.logger.warn result[:errors]
        result[:errors]
      end
    end

    def notify_user_creation(book)
      Rails.logger.warn 'ActiveSupport::Notifications está disponível nesta versão do Rails'
      # ActiveSupport::Notifications.instrument('book.update', book: book)
    end
  end
end
