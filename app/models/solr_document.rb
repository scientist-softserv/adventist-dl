# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocument

  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior
  include DogBiscuits::ExtendedSolrDocument

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.
  use_extension(Hydra::ContentNegotiation)

  attribute :extent, Solr::Array, solr_name('extent')
  attribute :rendering_ids, Solr::Array, solr_name('hasFormat', :symbol)
  attribute :slug, Solr::String, solr_name('slug')
  attribute :fedora_id, Solr::String, 'fedora_id_ssi'
  attribute :aark_id, Solr::String, 'aark_id_tesim'
  attribute :bibliographic_citation, Solr::String, solr_name('bibliographic_citation')
  attribute :alt, Solr::String, solr_name('alt')
  attribute :file_set_ids, Solr::Array, 'file_set_ids_ssim'
  attribute :video_embed, Solr::String, 'video_embed_tesim'

  def remote_url
    self[Solrizer.solr_name('remote_url')]
  end

  field_semantics.merge!(
    contributor: 'contributor_tesim',
    creator: 'creator_tesim',
    date: 'date_created_tesim',
    description: 'description_tesim',
    identifier: 'aark_id_tesim',
    language: 'language_tesim',
    publisher: 'publisher_tesim',
    relation: 'nesting_collection__pathnames_ssim',
    related_url: 'related_url_tesim',
    rights: 'rights_statement_tesim',
    subject: 'subject_tesim',
    title: 'title_tesim',
    type: 'human_readable_type_tesim'
  )

  def to_param
    slug || id
  end

  def thumbnail_url
    Addressable::URI.parse("https://#{Site.account.cname}#{thumbnail_path}").to_s
  end

  # @note This commented out method is supplanted by adding the `related_url: 'related_url_tesim`
  #       field semantics.
  # @note I'm commenting this out because in Bulkrax the source `related_url` (e.g. from the CSV or
  #       OAI ADL import) maps to `remote_files`.  The importers fetch the `remote_files` and attach
  #       them as FileSets.  They do not write to `related_url`.  However, there is also the ability
  #       to add a `related_url` via the UI.
  #
  # @see https://github.com/scientist-softserv/adventist-dl/issues/87
  # @see # https://github.com/scientist-softserv/adventist-dl/blob/96cbb01f1bd858ec0b472fb89ce033e180dba4b1/config/initializers/bulkrax.rb#L62
  # def related_url
  #   file_set_ids.map do |fs_id|
  #     Hyrax::Engine.routes.url_helpers.download_path(fs_id)
  #   end
  # end
end
