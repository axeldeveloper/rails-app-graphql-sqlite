module Mutations
  module Authors
    class CreateAuthor < ::Mutations::BaseMutation
      argument :date_of_birth, String, required: true
      argument :first_name, String, required: true
      argument :last_name, String, required: true

      type Types::AuthorType

      field :author, Types::AuthorType, null: true
      field :errors, [String], null: false

      def resolve(first_name:, last_name:, date_of_birth:)
        author = Author.new(
          date_of_birth: date_of_birth,
          first_name: first_name,
          last_name: last_name
        )

        if author.save
          { author: author, errors: [] }
        else
          { author: nil, errors: author.errors.full_messages }
        end
      end
    end
  end
end
