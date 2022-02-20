# frozen_string_literal: true

module Api
  module SymbolDetails
    private

    attr_accessor :symbol_details

    alias currency_pair_details symbol_details
    alias currency_pair_details= symbol_details=

    def populate_symbol_details(symbol)
      self.symbol_details = api.get.symbol_details(symbol)
    end
    alias refresh_symbol_details populate_symbol_details
    alias populate_currency_pair_details populate_symbol_details
    alias refresh_currency_pair_details populate_symbol_details

    def symbol_available_for_trade?(symbol_detailz)
      symbol_detailz.body.status == 'open'
    end
    alias currency_pair_available_for_trade? symbol_available_for_trade?
  end
end
