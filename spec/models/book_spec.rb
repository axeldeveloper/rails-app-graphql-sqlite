# frozen_string_literal: true

require 'rails_helper'

# teste para o modelo Book
# Verifica se o modelo Book está funcionando corretamente
RSpec.describe Book, type: :model do
  describe 'validations' do
    subject do
      described_class.new(
        title: 'Anything',
        genre: 'Horror',
        publication_date: DateTime.now,
        author_id: 1
      )
    end

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is not valid without a title' do
      subject.title = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without a genre' do
      subject.genre = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without a publication_date' do
      subject.publication_date = nil
      expect(subject).to_not be_valid
    end
  end

  describe 'genre enum' do
    it 'defines all expected genres' do
      expected_genres = Book::ALL_GENRES
      expect(Book.genres.keys).to match_array(expected_genres)

      expected_genres.each do |genre|
        expect(Book.genres[genre]).to eq(genre)
      end
    end

    it 'allows assigning valid genres' do
      Book::ALL_GENRES.each do |genre|
        book = described_class.new(
          title: 'Test',
          genre: genre,
          publication_date: DateTime.now,
          author_id: 1
        )

        expect(book.genre).to eq(genre)
        expect(book).to be_valid
      end
    end

    it 'raises error for invalid genre' do
      expect do
        described_class.new(
          title: 'Test',
          genre: 'InvalidGenre',
          publication_date: DateTime.now,
          author_id: 1
        )
      end.to raise_error(ArgumentError)
    end
  end
end
