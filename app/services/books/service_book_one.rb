# frozen_string_literal: true

# Exemplo de uso:
#
#   Books::ServiceBookOne.new(2).call
#
#
module Books
  class ServiceBookOne < ApplicationService
    def initialize(id)
      super()
      @book_id = id
    end

    def call
      Rails.logger.info("Fetching book with ID: #{@book_id}")
      BooksRepository.find(@book_id)
    end
  end
end
