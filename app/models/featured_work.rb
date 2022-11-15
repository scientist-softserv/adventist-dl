# frozen_string_literal: true

# OVERRIDE Hyrax 2.9.1 to change featured worked from 5 to 6

class FeaturedWork < ApplicationRecord
  FEATURE_LIMIT = 6
  validate :count_within_limit, on: :create
  validates :order, inclusion: { in: proc { 0..FEATURE_LIMIT } }

  default_scope { order(:order) }

  def count_within_limit
    return if FeaturedWork.can_create_another?
    errors.add(:base, "Limited to #{FEATURE_LIMIT} featured works.")
  end

  attr_accessor :presenter

  class << self
    def can_create_another?
      FeaturedWork.count < FEATURE_LIMIT
    end
  end
end
