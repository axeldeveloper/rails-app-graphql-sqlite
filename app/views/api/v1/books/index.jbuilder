# frozen_string_literal: true

json.array! @books, partial: 'api/v1/books/summary', as: :book

# Adicione uma mensagem se a coleção estiver vazia
#json.message 'No books found' if @books.empty?
