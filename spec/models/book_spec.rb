# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book, type: :model do
  subject do
    described_class.new(title: 'Anything', genre: 'Horror',
                        publication_date: DateTime.now, author_id: 1)
  end

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a title' do
    subject.title = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a genre' do
    subject.genre = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a publication_date' do
    subject.publication_date = nil
    expect(subject).to_not be_valid
  end
end
