FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    association :author
    genre { Book::ALL_GENRES.sample }
    # publication_date { 1.year.ago.to_date }
    publication_date { 2003 }
    trait :with_special_edition do
      genre { Book::ALL_GENRES.join(' ') }
    end
  end
  # usando
  # let(:special_book) { create(:book, :with_special_edition) }
end
