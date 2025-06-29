# frozen_string_literal: true

require "initable"

module Terminus
  module Actions
    module API
      module Devices
        # The index action.
        class Index < Base
          include Deps[repository: "repositories.device"]
          include Initable[serializer: Serializers::Device]

          def handle *, response
            data = repository.all.map { serializer.new(it).to_h }
            response.body = {data:}.to_json
          end
        end
      end
    end
  end
end
