# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL book queries', type: :request do
  let(:author) { create(:author, first_name: 'João', last_name: 'Silva') }
  let!(:book) do
    create(
      :book,
      title: 'Livro de teste',
      genre: 'Horror',
      publication_date: 2023,
      author: author
    )
  end

  describe 'books' do
    it 'returns books with their authors' do
      post '/graphql',
           params: {
             query: <<~GRAPHQL
               query {
                 books {
                   id
                   title
                   genre
                   publicationDate
                   author {
                     id
                     firstName
                     lastName
                   }
                 }
               }
             GRAPHQL
           },
           as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        'data' => {
          'books' => [
            {
              'id' => book.id.to_s,
              'title' => 'Livro de teste',
              'genre' => 'Horror',
              'publicationDate' => 2023,
              'author' => {
                'id' => author.id.to_s,
                'firstName' => 'João',
                'lastName' => 'Silva'
              }
            }
          ]
        }
      )
    end
  end

  describe 'book(id:)' do
    it 'returns the requested book' do
      post '/graphql',
           params: {
             query: <<~GRAPHQL,
               query FindBook($id: ID!) {
                 book(id: $id) {
                   id
                   title
                   genre
                   publicationDate
                 }
               }
             GRAPHQL
             variables: { id: book.id.to_s }
           },
           as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        'data' => {
          'book' => {
            'id' => book.id.to_s,
            'title' => 'Livro de teste',
            'genre' => 'Horror',
            'publicationDate' => 2023
          }
        }
      )
    end
  end
end
