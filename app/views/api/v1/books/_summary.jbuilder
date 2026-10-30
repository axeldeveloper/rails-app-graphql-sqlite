# frozen_string_literal: true

json.extract! book, :id, :title, :author_id, :genre, :publication_date
json.author do
  json.name book.author.first_name
end
# # This will also work
# json.id book.id
# json.title book.title
# json.genre book.genre
# json.publication_date book.publication_date
# json.created_at book.created_at
