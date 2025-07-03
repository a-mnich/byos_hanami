# frozen_string_literal: true

require "initable"
require "petail"

module Terminus
  module Actions
    module API
      module Devices
        # The show action.
        class Show < Base
          include Deps[repository: "repositories.device"]
          include Initable[serializer: Serializers::Device, problem: Petail]

          def handle request, response
            device = repository.find request.params[:id]

            response.body = if device
                              {data: serializer.new(device).to_h}.to_json
                            else
                              problem[status: :not_found].to_json
                            end
          end
        end
      end
    end
  end
end
