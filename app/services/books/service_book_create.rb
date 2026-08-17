# frozen_string_literal: true

module Books
  # Service object responsible for creating new books in the system
  class ServiceBookCreate < ApplicationService
    def initialize(book_param)
      super()
      @book_param = book_param
    end

    def call
      create_book
    end

    private

    def create_book
      result = BooksRepository.create(@book_param)
      if result[:success]
        notify_user_creation(result[:book])
        result[:book]
      else
        result[:errors]
      end
    end

    def notify_user_creation(book)
      Rails.logger.warn 'ActiveSupport::Notifications está disponível nesta versão do Rails'
      # Rails 6.0+
      # ActiveSupport::Notifications.instrument('book.created', book: book)

      # Rails 7.0+
      # ActiveSupport::Notifications.instrument('book.created') { { book: book } }

      # Ou usar Event
      # Rails 7.1+
      # Event.publish('book.created', book: book)
    end
  end
end
