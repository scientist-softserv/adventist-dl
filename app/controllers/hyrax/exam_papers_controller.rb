# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work ExamPaper`
module Hyrax
  # Generated controller for ExamPaper
  class ExamPapersController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::ExamPaper

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ExamPaperPresenter
  end
end
