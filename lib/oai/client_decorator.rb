module OAI
  # The purpose of this module is to work around the OAI implementation of Adventist; namely
  # the fact that after we pass make a resumption request, we loose our metadata_prefix context.
  #
  # Typically, the resumption token represents the full context of the previous request.  However,
  # in the Adventist implementation it's operating a bit like a pagination page indicator.
  #
  # @see https://github.com/scientist-softserv/adventist-dl/issues/271
  module ClientDecorator
    # @note override
    def do_resumable(responseClass, verb, opts)
      # NOTE: We need to close the options because throughout the life-cycle, the opts is deleted
      #       and updated.  This allows us to preserve
      original_options = opts.clone
      responseClass.new(do_request(verb, opts)) do |response|
        responseClass.new(
          do_request(verb, original_options.merge(:resumption_token => response.resumption_token))
        )
      end
    end

    # @note override
    def is_resumption?(opts)
      # The original method tested that the only key in the options was the resumption_token.  Which
      # if it wasn't would then raise an exception.
      return true if opts.keys.include?(:resumption_token)
      false
    end
  end
end

OAI::Client.prepend(OAI::ClientDecorator)
