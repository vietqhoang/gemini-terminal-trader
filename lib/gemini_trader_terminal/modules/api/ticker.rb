# frozen_string_literal: true

module Api
  module Ticker
    private

    attr_accessor :ticker

    def populate_ticker(symbol)
      self.ticker = api.get.ticker(symbol)
    end
    alias refresh_ticker populate_ticker
  end
end
