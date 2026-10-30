# frozen_string_literal: true

# Job
class WeeklyJob
  include Sidekiq::Worker

  def perform
    # Lógica do job semanal
    Rails.logger.info 'Executing weekly job'
  end
end
