unless defined?(ActiveSupport::Notifications)
  Rails.logger.warn 'ActiveSupport::Notifications não está disponível nesta versão do Rails'
end
