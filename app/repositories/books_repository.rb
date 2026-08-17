# Repository responsible for handling Author data persistence and queries
class BooksRepository
  class << self
    def find_all
      Rails.logger.info('BooksRepository Fetching books all')
      Book.all
    end

    def find(id)
      Rails.logger.info("BooksRepository Fetching book with ID: #{id}")
      Book.find(id)
    end

    def find_by_id(id)
      Rails.logger.info("BooksRepository Fetching book with ID: #{id}")
      Book.find_by(id: id)
    end

    def find_limit(limit)
      Book.all.top(limit)
    end

    def create(book_params)
      @book = Book.new(book_params)
      if @book.save
        { success: true, book: @book }
      else
        @errors = @book.errors.full_messages
        { success: false, errors: @errors }
      end
    end

    def update(book_id, book_params)
      @book = find(book_id)
      return { success: false, errors: ['Book not found 45'] } unless @book

      if @book.update(book_params)
        { success: true, book: @book }
      else
        @errors = @book.errors.full_messages
        { success: false, errors: @errors }
      end
    end

    def destroy(id)
      book = Book.find_by(id: id)
      book&.destroy
      book
    end

    def search_by_title(title)
      Book.where('title ILIKE ?', "%#{title}%")
    end
  end
end
