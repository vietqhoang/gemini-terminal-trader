# frozen_string_literal: true

require_relative 'base'

module GeminiApi
  # Gemini API interface for HTTP method POST
  class Post < Base
    def active_orders
      post(:active_orders)
    end

    def balances
      post(:balances)
    end

    def new_order(**parameters)
      post(:new_order, payload_options: parameters)
    end

    def notional_balances(currency)
      post(:notional_balances, currency)
    end

    def notional_volume
      post(:notional_volume)
    end

    def past_orders(**parameters)
      post(:past_orders, payload_options: parameters)
    end

    private

    def post(endpoint_key, resource = nil, payload_options: {})
      request(http_method: :post, endpoint_key: endpoint_key, resource: resource, payload_options: payload_options)
    end
  end
end
