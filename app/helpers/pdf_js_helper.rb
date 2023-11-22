# frozen_string_literal: true

module PdfJsHelper
  def pdf_js_url(file_set_presenter)
    # assumes that the download path exists if the file set has been characterized
    path = if file_set_presenter.mime_type
             hyrax.download_path(file_set_presenter.id)
           else
             file_set_presenter.solr_document["import_url_ssim"].first
           end

    "/pdf.js/web/viewer.html?file=#{path}##{query_param}"
  end

  def pdf_file_set_presenter(presenter)
    # currently only supports one pdf per work, falls back to the first pdf file set in ordered members

    # Commenting this line out because even PDFs that were not split will still have a representative media
    # which will be used first in this logic, consider uncommenting once all imports finish
    # representative_presenter(presenter) ||
    first_file_set_pdf(presenter)
  end

  def first_file_set_pdf(presenter)
    pdf_file_set_presenters = presenter.file_set_presenters.select(&:pdf?)
    reader, archival = pdf_file_set_presenters.partition do |fsp|
      fsp.solr_document["import_url_ssim"]&.first&.include? "READER"
    end

    reader.first || archival.first
  end

  def representative_presenter(presenter)
    presenter.file_set_presenters.find { |file_set_presenter| file_set_presenter.id == presenter.representative_id }
  end

  def query_param
    search_params = current_search_session.try(:query_params) || {}
    q = search_params['q'].presence || ''

    "search=#{q}&phrase=true"
  end
end
