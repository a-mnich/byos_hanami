# frozen_string_literal: true

module Terminus
  module Contracts
    module Devices
      # The contract for device creates.
      class Create < Dry::Validation::Contract
        params { required(:device).hash Schemas::Devices::Upsert }

        rule device: :sleep_start_at, &Rules::SleepStartAt
        rule device: :sleep_stop_at, &Rules::SleepStopAt
      end
    end
  end
end
