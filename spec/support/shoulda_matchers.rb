# frozen_string_literal: true

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end

  # config.include Request::JsonHelpers, type: :request
end
