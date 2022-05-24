module OAI
  module Provider
    module ModelDecorator
      # Map Qualified Dublin Core (Terms) fields to Oregon Digital fields
      def map_oai_qdc
        { :title => :title,
          :alternative => :alternative_title,
          :description => :description,
          :abstract => :abstract,
          :identifier => :identifier,
          :date => :date_created,
          :created => :created,
          :issued => :issued,
          :creator => :creator,
          :contributor => :contributor,
          :subject => :subject,
          :rights => :rights_statement,
          :rightsHolder => :rights_holder,
          :license => :license,
          :publisher => :publisher,
          :provenance => :provenance,
          :spatial => :location,
          :type => :type,
          :language => :language,
          :isPartOf => :is_part_of,
          :tableOfContents => :table_of_contents,
          :temporal => :temporal,
          :bibliographicCitation => :citation,
          :relation => :relation,
          :isReferencedBy => :finding_aid,
          :hasPart => :has_part,
          :isVersionOf => :is_version_of,
          :extent => :extent,
          :format => :format
        }
      end

      def map_oai_adl
        {
          :abstract => :abstract,
          :alternativeTitle => :alternative_title,
          :arkId => :ark_id,
          :bibliographicCitation => :bibliographic_citation,
          :contributor => :contributor,
          :created => :created,
          :creator => :creator,
          :date => :date_created,
          :dateAccepted => :date_accepted,
          :dateIssued => :date_issued,
          :description => :description,
          :edition => :edition,
          :extent => :extent,
          :geocode => :geocode,
          :hasPart => :has_part,
          :identifier => :identifier,
          :isPartOf => :is_part_of,
          :isVersionOf => :isVersionOf,
          :issueNumber=> :issue_number,
          :language => :language,
          :license => :license,
          :location => :location,
          :modified => :date_modified,
          :pagination => :pagination,
          :partOf => :part_of,
          :placeOfPublication => :place_of_publication,
          :publisher => :publisher,
          :relation => :relation,
          :remoteUrl => :remote_url,
          :resourceType => :resource_type,
          :rights => :rights_statement,
          :source => :source,
          :subject => :subject,
          :title => :title,
          :volumeNumber => :volume_number
        }
      end
    end
  end
end
OAI::Provider::Model.prepend(OAI::Provider::ModelDecorator)
