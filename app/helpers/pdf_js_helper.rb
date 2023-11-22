# frozen_string_literal: true

module PdfJsHelper
  def pdf_js_url(path)
    "/pdf.js/web/viewer.html?file=#{path}##{query_param}"
  end

  def pdf_file_set_presenter(presenter)
    # currently only supports one pdf per work, falls back to the first pdf file set in ordered members
    representative_presenter(presenter) || presenter.file_set_presenters.select(&:pdf?).first
  end

  def representative_presenter(presenter)
    presenter.file_set_presenters.find { |file_set_presenter| file_set_presenter.id == presenter.representative_id }
  end

  def query_param
    # return unless params[:q]

    search_params = current_search_session.try(:query_params) || {}
    q = search_params['q'].presence || ''

    "search=#{q}&phrase=true"
  end
end