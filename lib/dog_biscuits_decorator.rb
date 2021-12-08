# frozen_string_literal: true

module DogBiscuitsDecorator
  autoload_under 'app/models/dog_biscuits' do
    autoload :RemoteUrl
  end
end

::DogBiscuits.prepend(DogBiscuitsDecorator)
