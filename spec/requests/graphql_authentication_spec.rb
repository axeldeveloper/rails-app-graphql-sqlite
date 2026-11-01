# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength -- Keep GraphQL authorization scenarios together.
RSpec.describe 'GraphQL authentication', type: :request do
  let(:author) { create(:author) }
  let(:query) do
    <<~GRAPHQL
      query {
        books {
          id
          title
        }
      }
    GRAPHQL
  end
  let(:mutation) do
    <<~GRAPHQL
      mutation {
        createBook(title: "Protected book", authorId: #{author.id}, publicationDate: 2026, genre: Horror) {
          id
          title
        }
      }
    GRAPHQL
  end

  it 'allows public queries without an access token' do
    post '/graphql', params: { query: query }, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq('data' => { 'books' => [] })
  end

  it 'rejects mutations without an access token and does not create data' do
    post '/graphql', params: { query: mutation }, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('errors', 0, 'message')).to eq('Authentication required')
    expect(Book.where(title: 'Protected book')).to be_empty
  end

  it 'allows mutations with a valid access token' do
    user = create(:user)
    access_token = Authentication::AccessToken.issue(user)

    post '/graphql',
         params: { query: mutation },
         headers: { 'Authorization' => "Bearer #{access_token}" },
         as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('data', 'createBook', 'title')).to eq('Protected book')
    expect(Book.where(title: 'Protected book')).to exist
  end
end
# rubocop:enable Metrics/BlockLength
