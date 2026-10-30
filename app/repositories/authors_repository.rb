# frozen_string_literal: true

# module Repositories
# Repository responsible for handling Author data persistence and queries
class AuthorsRepository
  class << self
    def all
      Author.all
    end

    def find(id)
      Author.find(id)
    end

    def create(params)
      Rails.logger.info('AuthorsRepository: Criando novo autor')
      author = Author.new(params)
      if author.save
        Rails.logger.info("AuthorsRepository: Autor criado com sucesso - ID: #{author.id}")
        { success: true, author: author }
      else
        Rails.logger.error("AuthorsRepository: Falha ao criar autor - Erros: #{author.errors.full_messages}")
        { success: false, errors: author.errors.full_messages }
      end
    end

    def update(author_id, author_params)
      Rails.logger.info("AuthorsRepository: Atualizando autor ID: #{author_id}")
      @author = find(author_id)
      return { success: false, errors: ['Autor não encontrado'] } unless @author

      if @author.update(author_params)
        Rails.logger.info("AuthorsRepository: Autor atualizado com sucesso - ID: #{@author.id}")
        { success: true, author: @author }
      else
        Rails.logger.error("AuthorsRepository: Falha ao atualizar autor - Erros: #{@author.errors.full_messages}")
        { success: false, errors: @author.errors.full_messages }
      end
    end

    def destroy(id)
      author = find(id)
      author&.destroy
      Rails.logger.info("AuthorsRepository: destroy autor ID: #{author.id}")
      author
    end

    def find_with_books(id)
      Rails.logger.info("Fetching Author with ID: #{id}")
      Author.includes(:books).find(id)
    end

    def find_by_books_genre(genre)
      Author.joins(:books).where(books: { genre: genre }).distinct
    end

    def count_books_by_author(author_id)
      find(author_id).books.count
    end
  end
end
# end
