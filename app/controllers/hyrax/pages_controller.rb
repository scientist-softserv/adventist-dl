# frozen_string_literal: true
# OVERRIDE class from Hyrax v2.9.1

require_dependency Hyrax::Engine.root.join('app', 'controllers', 'hyrax', 'pages_controller').to_s

Hyrax::Controllers::PagesController.class_eval do

  # OVERRIDE: add resources page to permitted params
  private

  def permitted_params
    params.require(:content_block).permit(:about,
                                          :agreement,
                                          :help,
                                          :terms,
                                          :resources)
  end
end