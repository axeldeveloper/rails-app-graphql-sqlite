# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Authors', type: :request do
  describe 'GET /index' do
    it 'retorna uma lista de autores' do
      author = Author.create!(first_name: 'João', last_name: 'Silva', date_of_birth: '1990-01-01')
      author.books.create!(title: 'Livro 1', publication_date: 2020, genre: 'Horror')

      get '/api/v1/authors'

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)

      expect(json_response.length).to eq(1)
      expect(json_response.first['first_name']).to eq('João')
      expect(json_response.first['last_name']).to eq('Silva')
      expect(json_response.first['books'].length).to eq(1)
    end
  end
end
