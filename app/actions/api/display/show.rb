# frozen_string_literal: true

require "dry/monads"
require "initable"
require "trmnl/api"

module Terminus
  module Actions
    module API
      module Display
        # The show action.
        class Show < Base
          include Deps[
            :settings,
            firmware_repository: "repositories.firmware",
            image_fetcher: "aspects.screens.rotator",
            synchronizer: "aspects.devices.synchronizer"
          ]

          include Initable[model: TRMNL::API::Models::Display]
          include Dry::Monads[:result]

          using Refines::Actions::Response

          def handle request, response
            environment = request.env

            case synchronizer.call environment
              in Success(device)
                record = build_record fetch_image(request.params, environment, device), device
                response.with body: record.to_json, status: 200
              else not_found response
            end
          end

          private

          def fetch_image parameters, environment, device
            encryption = :base_64 if (environment["HTTP_BASE64"] || parameters[:base_64]) == "true"

            image_fetcher.call device, encryption:
          end

          def build_record image, device
            model[
              firmware_url: fetch_firmware_uri(device),
              **image.slice(:image_url, :filename),
              **device.as_api_display
            ]
          end

          # :reek:FeatureEnvy
          def fetch_firmware_uri device
            firmware_repository.latest.then do |firmware|
              break unless firmware
              break if device.firmware_version == firmware.version

              firmware.attachment_uri host: settings.api_uri
            end
          end

          def not_found response
            body = problem[
              type: "/problem_details#device_id",
              status: __method__,
              detail: "Invalid device ID.",
              instance: "/api/display"
            ]

            response.with body: body.to_json, format: :problem_details, status: 404
          end
        end
      end
    end
  end
end
