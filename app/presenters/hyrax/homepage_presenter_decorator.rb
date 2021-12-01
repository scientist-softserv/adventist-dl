# frozen_string_literal: true

module Hyrax
  module HomepagePresenterDecorator
    # add feature flag for featured researcher
    def display_featured_researcher?
      Flipflop.show_featured_researcher?
    end
  end
end

Hyrax::HomepagePresenter.prepend(Hyrax::HomepagePresenterDecorator)
