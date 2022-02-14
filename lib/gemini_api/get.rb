require_relative 'base'

module GeminiApi
  class Get < Base
    def symbols
      get(:symbols)
    end

    def symbol_details(symbol)
      get(:symbol_details, symbol)
    end

    def ticker(symbol)
      get(:ticker, symbol)
    end

    private

    def get(endpoint_key, resource = nil, payload_options: {})
      request(http_method: :get, endpoint_key: endpoint_key, resource: resource, payload_options: payload_options)
    end
  end
end
