# frozen_string_literal: true

namespace :report do
  desc 'Generate a report of users who logged in during the last week'
  task generate: :environment do
    # $ rake report:generate

    one_week_ago = 1.week.ago

    authors = Author.where('date_of_birth <= ?', one_week_ago)

    authors.each do |user|
      puts "Name: #{user.first_name}, Email: #{user.last_name}, Last Login: #{user.date_of_birth}"
    end
  end
end
