# frozen_string_literal: true

require "htmx"
require "refinements/hash"

module Terminus
  module Views
    # The view helpers.
    module Helpers
      extend Hanami::View::Helpers::TagHelper

      using Refinements::Hash

      module_function

      def boolean value
        css_class = value == true ? "text-green" : "text-red"
        tag.span value.to_s, class: css_class
      end

      def field_for key, attributes, record = nil
        return attributes[key] unless record

        attributes.fetch_value key, record.public_send(key)
      end

      def human_at(value) = (value.strftime "%B %d %Y at %H:%M %Z" if value)

      def human_time(value) = (value.strftime "%I:%M %p" if value)

      def size bytes, megabyte: 1_048_576.0
        return "0" unless bytes

        case bytes
          when ...megabyte then "#{bytes} B"
          else (bytes / megabyte).then { |megabytes| format("%.2f MB", megabytes).sub(".00", "") }
        end
      end
    end
  end
end
