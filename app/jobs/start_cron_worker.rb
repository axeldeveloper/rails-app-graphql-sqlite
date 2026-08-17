# frozen_string_literal: true

# Job

class StartCronWorker
  include Sidekiq::Worker
  # queue_as :default

  def perform(*_args)
    Rails.logger.info '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
    Rails.logger.info ' StartCronWorker  in 2 second'
    sleep 2

    job = Sidekiq::Cron::Job.new(name: 'Hard worker - every 5min', cron: '*/5 * * * *', class: 'HardWorker')
    if job.valid?
      job.save
    else
      Rails.logger.info job.errors
    end

    Rails.logger.info "Book created with ID: #{job}"
  end
end
