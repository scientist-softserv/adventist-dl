# frozen_string_literal: true

#
# Behavior to handle ordered fields
# use `ordered_field :field_name` in Work Type
#
module OrderedBehavior
  extend ActiveSupport::Concern

  included do
    def self.ordered_field(name)
      define_method(name.to_s) do
        OrderedStringService.deserialize(super())
      end

      define_method("#{name}=") do |values|
        super(sanitize_n_serialize(values))
      end
    end
  end

  #
  # Sanitize and serialize person data
  #
  def sanitize_n_serialize(values)
    full_sanitizer = Rails::Html::FullSanitizer.new
    sanitized_values = Array.new(values.size, '')
    empty = OrderedStringService::TOKEN_DELIMITER * 3
    values.each_with_index do |v, i|
      sanitized_values[i] = full_sanitizer.sanitize(v) unless v == empty
    end
    OrderedStringService.serialize(sanitized_values)
  end
end
