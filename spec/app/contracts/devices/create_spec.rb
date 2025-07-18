# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Contracts::Devices::Create do
  subject(:contract) { described_class.new }

  describe "#call" do
    let :attributes do
      {
        device: {
          model_id: 1,
          label: "Test",
          friendly_id: "ABC123",
          mac_address: "AA:BB:CC:11:22:33",
          api_key: "secret",
          refresh_rate: 100,
          image_timeout: 0,
          proxy: "on",
          firmware_update: "on",
          sleep_start_at: "01:00:00",
          sleep_stop_at: "02:00:00"
        }
      }
    end

    it_behaves_like "a sleep contract"
  end
end
