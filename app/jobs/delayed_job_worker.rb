# frozen_string_literal: true

# Job

require 'net/http'
require 'json'

class DelayedJobWorker
  include Sidekiq::Worker

  def perform(book_id)
    # book = Book.find_by(id: book_id)
    # book = ::Books::BookListQuery.find_by_id(book_id)
    book =  BooksRepository.find_by_id(book_id)
    if book
      # Invocar a API para obter o status do livro
      response = fetch_book_status(book_id)
      puts response

      # Verificar se o status é diferente de "pending"
      if response['status'] == 'pending'
        Rails.logger.info "Status do livro com ID #{book_id} é pending."
      else
        Rails.logger.info "Status do livro com ID #{book_id} é diferente de pending: #{response['status']}"
        # Adicione a lógica que deseja executar quando o status não for "pending"
      end
    else
      Rails.logger.error "Livro com ID #{book_id} não encontrado."
    end
  end

  private 
  
  def fetch_book_status(book_id)
    # Substitua esta URL pela URL da sua API
    url = URI("http://localhost:3000/api/v1/books/#{book_id}")

    # Fazer a chamada HTTP GET
    response = Net::HTTP.get(url)

    # Analisar a resposta JSON
    JSON.parse(response)
  rescue StandardError => e
    Rails.logger.error "Erro ao chamar a API para o livro com ID #{book_id}: #{e.message}"
    {}
  end
end
