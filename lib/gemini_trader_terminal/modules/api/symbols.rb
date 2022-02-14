module Api
  module Symbols
    private

    attr_accessor :symbols

    alias :currency_pairs :symbols
    alias :currency_pairs= :symbols=

    def populate_symbols
      self.symbols = api.get.symbols
    end
    alias_method :refresh_symbols, :populate_symbols
    alias_method :populate_currency_pairs, :populate_symbols
    alias_method :refresh_currency_pairs, :populate_symbols
  end
end
