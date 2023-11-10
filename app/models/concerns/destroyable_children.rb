# frozen_string_literal: true

module DestroyableChildren
  extend ActiveSupport::Concern

  included do
    before_destroy :destroy_children
  end

  private

    def destroy_children
      ordered_works.each(&:destroy)
    end
end
