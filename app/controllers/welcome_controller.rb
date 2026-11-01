# frozen_string_literal: true

class WelcomeController < ActionController::API
  # layout 'application'

  def index
    request.content_security_policy = nil # a CSP vem da meta tag do index.html
    send_file Rails.public_path.join('index.html'),
              type: 'text/html', disposition: 'inline'
  end

  def index2
    # Your action code here
  end
end
