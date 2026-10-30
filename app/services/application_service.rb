# frozen_string_literal: true

class ApplicationService
  # DRY(Don't Repeat Yourself)
  def self.call(*ags, &)
    # Rails.log '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
    # Rails.log "DRY(Don't Repeat Yourself)"
    # Rails.log block

    new(*ags, &).call
  end
end
