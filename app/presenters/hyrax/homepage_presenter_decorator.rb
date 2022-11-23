# frozen_string_literal: true

module Hyrax
  module HomepagePresenterDecorator
    # add feature flag for featured researcher
    def display_featured_researcher?
      Flipflop.show_featured_researcher?
    end

    def display_share_button?
      Flipflop.show_share_button? && current_ability.can_create_any_work? ||
        Flipflop.show_share_button? && user_unregistered?
    end
  end
end

Hyrax::HomepagePresenter.prepend(Hyrax::HomepagePresenterDecorator)
