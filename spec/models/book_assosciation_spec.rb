# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book, type: :model do
  subject do
    described_class.new(title: 'Anything',
                        genre: 'Horror',
                        publication_date: DateTime.now,
                        author_id: 1)
  end

  it 'Belongs to a author' do
    should belong_to(:author).without_validating_presence
  end

  it 'Associations' do
    # should belong_to(:user).without_validating_presence
  end
end
