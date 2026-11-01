# frozen_string_literal: true

# module Mutations
#  class BaseMutation < GraphQL::Schema::RelayClassicMutation
#    argument_class Types::BaseArgument
#    field_class Types::BaseField
#    input_object_class Types::BaseInputObject
#    object_class Types::BaseObject
#  end
# end

module Mutations
  # Requires an authenticated account before resolving any GraphQL mutation.
  class BaseMutation < GraphQL::Schema::Mutation
    null false

    def ready?(**_arguments)
      raise GraphQL::ExecutionError, 'Authentication required' unless context[:current_user]

      true
    end
  end
end
