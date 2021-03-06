# frozen_string_literal: true

require "pulsedive"

module Mihari
  module Analyzers
    class Pulsedive < Base
      attr_reader :query
      attr_reader :type

      attr_reader :title
      attr_reader :description
      attr_reader :tags

      def initialize(query, title: nil, description: nil, tags: [])
        super()

        @query = query
        @type = TypeChecker.type(query)

        @title = title || "Pulsedive lookup"
        @description = description || "query = #{query}"
        @tags = tags
      end

      def artifacts
        lookup || []
      end

      private

      def config_keys
        %w(pulsedive_api_key)
      end

      def api
        @api ||= ::Pulsedive::API.new(Mihari.config.pulsedive_api_key)
      end

      def valid_type?
        %w(ip domain).include? type
      end

      def lookup
        raise InvalidInputError, "#{query}(type: #{type || 'unknown'}) is not supported." unless valid_type?

        indicator = api.indicator.get_by_value(query)
        iid = indicator.dig("iid")

        properties = api.indicator.get_properties_by_id(iid)
        (properties.dig("dns") || []).map do |property|
          property.dig("value") if ["A", "PTR"].include?(property.dig("name"))
        end.compact
      end
    end
  end
end
