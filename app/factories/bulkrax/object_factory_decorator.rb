# frozen_string_literal: true

module Bulkrax
  module ObjectFactoryDecorator
    # @param [Hash] attrs the attributes to put in the environment
    # @return [Hyrax::Actors::Environment]
    def environment(attrs)
      Hyrax::Actors::Environment.new(object, Ability.new(@user), attrs, true)
    end
  end
end

::Bulkrax::ObjectFactory.prepend(Bulkrax::ObjectFactoryDecorator)
