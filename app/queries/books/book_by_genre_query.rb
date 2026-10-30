# frozen_string_literal: true

module Books
  class BookByGenreQuery
    def initialize(genre:)
      @genre = genre
    end

    def call
      scope = Book.where(genre: @genre)
      scope.order(:title)
    end
  end
end
