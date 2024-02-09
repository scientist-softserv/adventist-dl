# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  before_enqueue :set_auxiliary_queue_priority

  # limit to 5 attempts
  retry_on StandardError, wait: :exponentially_longer, attempts: 5 do |_job, _exception|
    # Log error, do nothing, etc.
  end

  private

    def set_auxiliary_queue_priority
      # TODO: make ENV variable
      self.priority = 100 if queue_name.to_sym == :auxiliary
    end
end
