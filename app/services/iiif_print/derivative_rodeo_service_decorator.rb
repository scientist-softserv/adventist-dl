##
# OVERRIDE: This is in play to to introduce additional logging to see where things are faililng.
module IiifPrint
  module DerivativeRodeoServiceDecorator
    module ClassMethods
      def derivative_rodeo_preprocessed_directory_for(file_set:, filename:)
        # In the case of a page split from a PDF, we need to know the grandparent's identifier to
        # find the file(s) in the DerivativeRodeo.
        ancestor_type = nil
        ancestor = if DerivativeRodeo::Generators::PdfSplitGenerator.filename_for_a_derived_page_from_a_pdf?(filename: filename)
                     ancestor_type = :grandparent
                     IiifPrint.grandparent_for(file_set)
                   else
                     ancestor_type = :parent
                     IiifPrint.parent_for(file_set)
                   end
        # Why might we not have an ancestor?  In the case of grandparent_for, we may not yet have run
        # the create relationships job.  We could sneak a peak in the table to maybe glean some insight.
        # However, read further the `else` clause to see the novel approach.
        if ancestor
          message = "#{self.class}.#{__method__} #{file_set.class} ID=#{file_set.id} and filename: #{filename.inspect}" \
                    "has #{ancestor_type} of #{ancestor.class} ID=#{ancestor.id}"
          Rails.logger.info(message)
          ancestor.public_send(parent_work_identifier_property_name) ||
            raise("Expected #{ancestor.class} ID=#{ancestor.id} (#{ancestor_type} of #{file_set.class} ID=#{file_set.id}) " \
                  "to have a present #{parent_work_identifier_property_name.inspect}")
        else
          # HACK: This makes critical assumptions about how we're creating the title for the file_set;
          # but we don't have much to fall-back on.  Consider making this a configurable function.  Or
          # perhaps this entire method should be more configurable.
          # TODO: Revisit this implementation.
          file_set.title.first.split(".").first ||
            raise("#{file_set.class} ID=#{file_set.id} has title #{file_set.title.first} from which we cannot infer information.")
        end
      end
    end
  end
end

IiifPrint::DerivativeRodeoService.singleton_class.send(:prepend, IiifPrint::DerivativeRodeoServiceDecorator::ClassMethods)
