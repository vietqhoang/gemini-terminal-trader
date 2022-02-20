# frozen_string_literal: true

require_relative 'api/symbols'

# Transforms currency pairs into a charting object to be able to match two currencies to their currency pair
module QuoteCurrencyPairChart
  include Api::Symbols

  SIMILARLY_NAMED_CURRENCIES = {
    'usd' => %w[gusd]
  }.freeze

  private

  attr_accessor :currency_pair, :quote_currency_pair_chart

  def populate_quote_currency_pair_chart(quote_currencies)
    populate_currency_pairs

    self.quote_currency_pair_chart =
      currency_pairs_grouped_by_quote_currency(quote_currencies).each_with_object({}) do |(quote_currency, currency_pairz), hash|
        hash[quote_currency] =
          currency_pairz.each_with_object({}) do |currency_pair, subhash|
            subhash[currency_pair.delete_suffix(quote_currency)] = currency_pair
          end
      end
  end
  alias refresh_quote_currency_pair_chart populate_quote_currency_pair_chart

  def currency_pairs_grouped_by_quote_currency(quote_currencies)
    quote_currencies.each_with_object({}) do |quote_currency, hash|
      hash[quote_currency] =
        currency_pairs.body.select do |currency_pair|
          next false if matches_with_similarly_named_currency?(quote_currency, currency_pair)

          currency_pair.end_with?(quote_currency)
        end
    end
  end

  def matches_with_similarly_named_currency?(quote_currency, currency_pair)
    SIMILARLY_NAMED_CURRENCIES.value?(quote_currency) && SIMILARLY_NAMED_CURRENCIES[quote_currency].any? { |similary_named_currency| currency_pair.end_with?(similary_named_currency) }
  end

  def populate_currency_pair(quote_currency, base_currency)
    self.currency_pair = quote_currency_pair_chart[quote_currency][base_currency]
  end
  alias refresh_currency_pair populate_currency_pair
end
