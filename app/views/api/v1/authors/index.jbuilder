# frozen_string_literal: true

json.array! @authors do |a|
  # next if comment.marked_as_spam_by?(current_user)
  json.id a.id
  json.first_name a.first_name
  json.last_name a.last_name
  json.date_of_birth a.date_of_birth
  json.created_at a.created_at

  json.books a.books do |book|
    json.partial! 'api/v1/books/summary', book: book
  end

  # json.array! a.books, partial: 'api/v1/books/summary', as: :book
end
