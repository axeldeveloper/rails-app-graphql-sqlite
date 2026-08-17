# frozen_string_literal: true

# Exemplo de uso:
#
#   Books::ServiceBookList.call
#   
#
module Books
  class ServiceBookList < ApplicationService
    def call
      BooksRepository.find_all
    end
  end
end
