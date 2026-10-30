# frozen_string_literal: true

# Job

class HardWorker
  include Sidekiq::Worker
  # queue_as :default

  def perform(*args)
    Rails.logger.info '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
    Rails.logger.info "HardWorker with args: #{args}"
    Rails.logger.info ' HardWorker  in'
    sleep 2
  end
end
