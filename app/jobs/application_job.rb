# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  before_enqueue :set_auxiliary_queue_priority

  # limit to 5 attempts
  retry_on StandardError, wait: :exponentially_longer, attempts: 5 do |_job, _exception|
    # Log error, do nothing, etc.
  end

  private

    def set_auxiliary_queue_priority
      return unless queue_name.to_sym == :auxiliary

      self.priority = ENV.fetch('AUXILIARY_QUEUE_PRIORITY', 100).to_i
    end
end
