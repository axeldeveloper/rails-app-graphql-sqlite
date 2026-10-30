# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Books', type: :request do
  describe 'GET /index' do
    it 'retorna uma lista de livros com os dados do autor' do
      author = create(:author, first_name: 'João', last_name: 'Silva')
      book = create(
        :book,
        title: 'Livro de teste',
        publication_date: 2023,
        genre: 'Drama',
        author: author
      )

      get '/api/v1/books'

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('application/json')
      expect(response.parsed_body).to eq(
        [
          {
            'id' => book.id,
            'title' => 'Livro de teste',
            'author_id' => author.id,
            'genre' => 'Drama',
            'publication_date' => 2023,
            'author' => { 'name' => 'João' }
          }
        ]
      )
    end

    it 'retorna uma lista vazia quando não há livros' do
      get '/api/v1/books'

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('application/json')
      expect(response.parsed_body).to eq([])
    end
  end
end
