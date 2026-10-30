# frozen_string_literal: true

# Job
class UserRandomUpdateJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Rails.logger.info '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
    Rails.logger.info ':: UserRandomUpdateJob :: '
    message = "Book update info with ID: => #{randomize_id}"
    Rails.logger.info message
    sleep 10
  end

  def randomize_id
    # Using Postgresql or SQLite, using RANDOM():
    # id = Book.order("RANDOM()").first.id
    Book.find(Book.pluck(:id).sample).id

    # id = Book.first(offset: rand(Book.count)).id
    # begin
    #  id = SecureRandom.random_number(1_000_000)
    # end while Book.where(id: id).exists?
  end
end
