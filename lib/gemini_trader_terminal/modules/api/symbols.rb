# frozen_string_literal: true

module Api
  module Symbols
    private

    attr_accessor :symbols

    alias currency_pairs symbols
    alias currency_pairs= symbols=

    def populate_symbols
      self.symbols = api.get.symbols
    end
    alias refresh_symbols populate_symbols
    alias populate_currency_pairs populate_symbols
    alias refresh_currency_pairs populate_symbols
  end
end
