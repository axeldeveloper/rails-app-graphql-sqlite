require 'rails_helper'

# teste de criação de livro
RSpec.describe Api::V1::BooksController, type: :controller do
  render_views

  describe 'GET #index' do
    let(:author) { create(:author) }
    let!(:books) { create_list(:book, 4, author: author) }

    it 'retorna todos os livros' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match('application/json')
      json = response.parsed_body
      expect(json).to be_an(Array)
      expect(json.length).to be >= 1
      expect(json).not_to be_empty
      expect(json.first).to include(
        'id' => be_kind_of(Integer),
        'title' => be_kind_of(String),
        'genre' => be_kind_of(String),
        'publication_date' => be_kind_of(Integer),
        'author' => include('name' => be_kind_of(String))
      )
    end
  end

  describe 'GET #show' do
    let(:author) { Author.create!(first_name: 'João', last_name: 'Silva', date_of_birth: '1990-01-01') }
    let(:book) do
      Book.create!(title: 'Livro Original', publication_date: '2023-01-01', genre: 'Drama', author_id: author.id)
    end
    context 'quando book existe' do
      it 'retorna o livro com sucesso' do
        get :show, params: { id: book.id }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match('application/json')
        json = response.parsed_body
        expect(json['title']).to eq('Livro Original')
        expect(json['genre']).to eq('Drama')
        expect(json['publication_date']).to eq(2023)
        expect(json['author']).to include('name' => 'João')
      end
    end

    context 'quando book não existe' do
      it 'retorna erro not_found' do
        get :show, params: { id: 9999 }
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to include(
          'success' => false,
          'error' => 'Recurso não encontrado'
        )
      end
    end
  end

  describe 'POST #create' do
    # Criar um author antes dos testes
    let(:author) { Author.create!(first_name: 'João', last_name: 'Silva', date_of_birth: '1990-01-01') }
    context 'quando parâmetros obrigatórios estão faltando' do
      it 'retorna erro quando book não está presente' do
        post :create, params: {}
        expect(response).to have_http_status(:bad_request)
        data = {
          'success' => false,
          'error' => include('param is missing or the value is empty: book')
        }
        expect(JSON.parse(response.body)).to match(data)
      end

      it 'retorna erro quando book está vazio' do
        post :create, params: { book: {} }

        expect(response).to have_http_status(:bad_request)
        data = {
          'success' => false,
          'error' => include('param is missing or the value is empty: book')
        }
        expect(JSON.parse(response.body)).to match(data)
      end
    end

    context 'quando os parâmetros são válidos' do
      let(:valid_params) do
        {
          book: {
            title: 'O Senhor dos Anéis',
            publication_date: '1954-07-29',
            genre: 'Horror',
            author_id: author.id
          }
        }
      end

      it 'cria um novo livro com sucesso' do
        post :create, params: valid_params, format: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match('application/json')
        json = response.parsed_body
        # expect(json['success']).to be true
        expect(json['title']).to eq('O Senhor dos Anéis')
        expect(json).to include(
          'id' => be_kind_of(Integer),
          'title' => 'O Senhor dos Anéis',
          'genre' => 'Horror'
        )
        expect(json['genre']).to eq('Horror')
      end
    end

    context 'quando o livro não é criado' do
      it 'retorna erro quando o livro não é criado' do
        post :create, params: { book: { title: 'O Senhor dos Anéis' } }
        expect(response).to have_http_status(:unprocessable_entity)
        # A resposta JSON deve ter a estrutura correta com o sucesso, erro e mensagens de validação
        data = {
          'success' => false,
          'error' => 'Validation failed',
          'details' => [
            "Publication date can't be blank",
            "Genre can't be blank"
          ]
        }

        expect(JSON.parse(response.body)).to match(data)
      end
    end
  end

  describe 'PUT #update' do
    let(:author) { Author.create!(first_name: 'João', last_name: 'Silva', date_of_birth: '1990-01-01') }
    let(:book) do
      Book.create!(title: 'Livro Original', publication_date: '2023-01-01', genre: 'Drama', author_id: author.id)
    end

    context 'quando os parâmetros são válidos' do
      let(:valid_params) do
        {
          id: book.id,
          book: {
            title: 'Novo Título',
            publication_date: '2023-02-01',
            genre: 'Comedy',
            author_id: author.id
          }
        }
      end

      it 'atualiza o livro com sucesso' do
        put :update, params: valid_params
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['title']).to eq('Novo Título')
        expect(json['genre']).to eq('Comedy')
      end
    end

    context 'quando o livro não existe' do
      it 'retorna erro not found 45' do
        put :update, params: { id: 999_999, book: { title: 'Novo Título' } }
        expect(response).to have_http_status(:not_found)
        json = response.parsed_body
        expect(json['success']).to be false
        expect(json['error']).to include("Couldn't find Book")
      end
    end

    context 'quando os parâmetros são inválidos' do
      it 'retorna erro de validação' do
        put :update, params: { id: book.id, book: { title: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
        json = response.parsed_body
        expect(json['success']).to be false
        expect(json['error']).to eq('Validation failed')
        expect(json['details']).to include("Title can't be blank")
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:author) { Author.create!(first_name: 'João', last_name: 'Silva', date_of_birth: '1990-01-01') }
    let(:book) do
      Book.create!(title: 'Livro Original', publication_date: '2023-01-01', genre: 'Drama', author_id: author.id)
    end

    it 'deleta o livro com sucesso' do
      delete :destroy, params: { id: book.id }
      expect(response).to have_http_status(:no_content)
    end
  end
end
