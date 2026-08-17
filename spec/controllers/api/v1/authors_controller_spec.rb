require 'rails_helper'

RSpec.describe Api::V1::AuthorsController, type: :controller do
  render_views

  describe 'GET #index' do
    let!(:authors) { create_list(:author, 3) }

    it 'retorna lista de autores' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.size).to eq(3)
    end
  end

  describe 'GET #show' do
    let(:author) { create(:author) }

    context 'quando autor existe' do
      it 'retorna autor com sucesso' do
        get :show, params: { id: author.id }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match('application/json')
        expect(response.parsed_body).to include(
          'id' => author.id,
          'first_name' => author.first_name,
          'last_name' => author.last_name
        )
      end
    end

    context 'quando autor não existe' do
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
    context 'com parâmetros válidos' do
      let(:valid_params) do
        {
          author: {
            first_name: 'John',
            last_name: 'Doe',
            date_of_birth: '1990-01-01'
          }
        }
      end

      it 'cria um novo autor' do
        expect do
          post :create, params: valid_params
        end.to change(Author, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to include(
          'first_name' => 'John',
          'last_name' => 'Doe'
        )
      end
    end

    context 'com parâmetros inválidos' do
      let(:invalid_params) do
        { author: { first_name: '' } }
      end

      it 'não cria autor e retorna erros' do
        expect do
          post :create, params: invalid_params
        end.not_to change(Author, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to include(
          'success' => false,
          'error' => 'Validation failed'
        )
      end
    end
  end

  describe 'PUT #update' do
    let(:author) { create(:author) }

    context 'com parâmetros válidos' do
      let(:update_params) do
        {
          id: author.id,
          author: { first_name: 'Jane' }
        }
      end

      it 'atualiza o autor' do
        put :update, params: update_params

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(
          'first_name' => 'Jane'
        )
        expect(author.reload.first_name).to eq('Jane')
      end
    end

    context 'com parâmetros inválidos' do
      let(:invalid_params) do
        {
          id: author.id,
          author: { first_name: '' }
        }
      end

      it 'não atualiza e retorna erros' do
        put :update, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to include(
          'success' => false,
          'error' => 'Validation failed'
        )
      end
    end

    context 'quando autor não existe' do
      it 'retorna erro not_found' do
        put :update, params: { id: 9999, author: { first_name: 'Jane' } }

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to include(
          'success' => false,
          'error' => "Couldn't find Author with 'id'=9999"
        )
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:author) { create(:author) }

    context 'quando autor existe' do
      it 'remove o autor' do
        expect do
          delete :destroy, params: { id: author.id }
        end.to change(Author, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'quando autor não existe' do
      it 'retorna erro not_found' do
        delete :destroy, params: { id: 9999 }

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to include(
          'success' => false,
          'error' => 'Recurso não encontrado'
        )
      end
    end
  end
end
