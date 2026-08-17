# frozen_string_literal: true

# bundle exec rake db:seed:single SEED=posts_seed
authors = [
  { first_name: 'Stephen', last_name: 'King', date_of_birth: Date.parse('1947-09-21') },
  { first_name: 'Lee', last_name: 'King', date_of_birth: Date.parse('1957-09-21') },
  { first_name: 'Tchala', last_name: 'King', date_of_birth: Date.parse('1967-09-21') }
]

authors.each do |a|
  Rails.logger.info "CREATE AUTHOR #{a[:name]}"
  Author.find_or_create_by(
    first_name: a[:first_name],
    last_name: a[:last_name],
    date_of_birth: a[:date_of_birth]
  )
end
