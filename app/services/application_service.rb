# frozen_string_literal: true

class ApplicationService
  # DRY(Don't Repeat Yourself)
  def self.call(*ags, &block)
    #Rails.log '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
    #Rails.log "DRY(Don't Repeat Yourself)"
    #Rails.log block

    new(*ags, &block).call
  end
end
