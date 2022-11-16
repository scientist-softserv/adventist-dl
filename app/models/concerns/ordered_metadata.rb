# frozen_string_literal: true

#
# Load in our ordered fields
#
module OrderedMetadata
  extend ActiveSupport::Concern

  included do
    include OrderedMetadata
    ordered_field :creator
  end

end
