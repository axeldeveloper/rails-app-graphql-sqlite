# frozen_string_literal: true

Rails.logger.info 'Creating seed data'

authors = [
  { first_name: 'Stephen', last_name: 'King', date_of_birth: '1947-09-21', book: 'The Midnight Library' },
  { first_name: 'Lee', last_name: 'Child', date_of_birth: '1954-10-29', book: 'The Silent Witness' },
  { first_name: 'Tchala', last_name: 'King', date_of_birth: '1967-09-21', book: 'Shadows Over the Harbor' },
  { first_name: 'Agatha', last_name: 'Christie', date_of_birth: '1890-09-15', book: 'The Clockmakers Secret' },
  { first_name: 'Ursula', last_name: 'Le Guin', date_of_birth: '1929-10-21', book: 'A Map of Distant Stars' },
  { first_name: 'Octavia', last_name: 'Butler', date_of_birth: '1947-06-22', book: 'The Glass Orchard' },
  { first_name: 'Arthur', last_name: 'Clarke', date_of_birth: '1917-12-16', book: 'Beyond the Red Horizon' },
  { first_name: 'Mary', last_name: 'Shelley', date_of_birth: '1797-08-30', book: 'The Winter Garden' },
  { first_name: 'Jorge', last_name: 'Amado', date_of_birth: '1912-08-10', book: 'The Lanterns of Bahia' },
  { first_name: 'Clarice', last_name: 'Lispector', date_of_birth: '1920-12-10', book: 'Letters from the Blue House' }
]

genres = %w[Horror Thriller Mystery]

authors.each_with_index do |attributes, index|
  author = Author.find_or_create_by!(
    first_name: attributes[:first_name],
    last_name: attributes[:last_name],
    date_of_birth: attributes[:date_of_birth]
  )

  author.books.find_or_create_by!(title: attributes[:book]) do |book|
    book.publication_date = 2000 + index
    book.genre = genres[index % genres.length]
  end
end

Rails.logger.info "Created or found #{authors.length} authors and #{authors.length} books"
