# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author, type: :model do
  context 'with 2 or more books' do
    it 'author with books' do
      # let(:a) { create(:author) }
      a = create(:author)
      a1 = create(:book, author: a, title: 'first comment', publication_date: 1978, genre: 'Action')
      a2 = create(:book, author: a, title: 'second comment', publication_date: 1977, genre: 'Horror')
      # Espera-se que o livro mais recente (a1) venha antes do livro mais antigo (a2)
      expect(a.books.order(publication_date: :desc)).to eq([a2, a1])
      # expect(a.books.order(publication_date: :desc)).to include([a1, a2])
      # expect(a.books.order(publication_date: :desc)).to include(a2)
    end

    it 'Manys books' do
      should have_many(:books)
    end
  end
end
