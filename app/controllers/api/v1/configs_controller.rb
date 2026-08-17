module Api
  module V1
    class ConfigsController < Api::ApplicationApiController
      def index
        configs = {
          rails_max_threads: ENV.fetch("RAILS_MAX_THREADS") { 5 },
          # Adicione outras configurações aqui
          database_host: ENV['DATABASE_HOST'],
          database_port: ENV['DATABASE_PORT'],
          # ... outras variáveis de ambiente ...
        }

        render json: configs
      end
    end
  end
end