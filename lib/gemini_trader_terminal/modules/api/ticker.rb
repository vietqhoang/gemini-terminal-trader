# frozen_string_literal: true

module Api

  # Helpers related to Gemini API ticker endpoint
  module Ticker
    private

    attr_accessor :ticker

    def populate_ticker(symbol)
      self.ticker = api.get.ticker(symbol)
    end
    alias refresh_ticker populate_ticker
  end
end
