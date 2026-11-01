# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength -- Keep protected-write scenarios together.
RSpec.describe 'Protected API writes', type: :request do
  let(:author) { create(:author) }
  let(:book) { create(:book, author: author) }
  let(:access_token) { Authentication::AccessToken.issue(create(:user)) }
  let(:authorization) { { 'Authorization' => "Bearer #{access_token}" } }

  it 'rejects unauthenticated book creation without persisting it' do
    author

    expect do
      post '/api/v1/books',
           params: { book: { title: 'Private write', publication_date: 2026, genre: 'Horror', author_id: author.id } },
           as: :json
    end.not_to change(Book, :count)

    expect(response).to have_http_status(:unauthorized)
  end

  it 'accepts authenticated book creation' do
    author

    post '/api/v1/books',
         params: { book: { title: 'Authorized write', publication_date: 2026, genre: 'Horror', author_id: author.id } },
         headers: authorization,
         as: :json

    expect(response).to have_http_status(:created)
    expect(Book.exists?(title: 'Authorized write')).to be(true)
  end

  it 'rejects unauthenticated book updates without changing the book' do
    book

    put "/api/v1/books/#{book.id}",
        params: { book: { title: 'Changed without token' } },
        as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(book.reload.title).not_to eq('Changed without token')
  end

  it 'rejects unauthenticated book deletion without deleting the book' do
    book

    delete "/api/v1/books/#{book.id}"

    expect(response).to have_http_status(:unauthorized)
    expect(Book.exists?(book.id)).to be(true)
  end

  it 'rejects unauthenticated author creation without persisting it' do
    expect do
      post '/api/v1/authors',
           params: { author: { first_name: 'Unauthorized', last_name: 'Writer', date_of_birth: '1990-01-01' } },
           as: :json
    end.not_to change(Author, :count)

    expect(response).to have_http_status(:unauthorized)
  end

  it 'rejects unauthenticated author updates and deletions' do
    author

    put "/api/v1/authors/#{author.id}",
        params: { author: { first_name: 'Unauthorized update' } },
        as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(author.reload.first_name).not_to eq('Unauthorized update')

    delete "/api/v1/authors/#{author.id}"

    expect(response).to have_http_status(:unauthorized)
    expect(Author.exists?(author.id)).to be(true)
  end

  it 'keeps REST reads public' do
    author

    get '/api/v1/books'

    expect(response).to have_http_status(:ok)
  end
end
# rubocop:enable Metrics/BlockLength
