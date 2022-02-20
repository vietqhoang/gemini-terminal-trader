# frozen_string_literal: true

require_relative 'base'
require_relative 'modules/api/balances'

module GeminiTraderTerminal
  # Interactive terminal which is responsible for balances
  class Balances < Base
    include Api::Balances

    def initialize(**attributes)
      super

      populate_notional_balances
      display_balances
    end

    private

    def display_balances
      prompt_say_table do |table|
        table.title = balances_table_title
        table.headings = balances_table_headings

        balance_currencies.each { |balance| table.add_row(balance_table_row(balance)) }
      end
    end

    def balances_table_title
      "Account balance as of #{notional_balances.response_at.iso8601} for #{environment} environment"
    end

    def balances_table_headings
      [
        'Currency',
        "Amount (#{default_fiat_currency.upcase} equivalent)",
        "Available for trade (#{default_fiat_currency.upcase} equivalent)"
      ]
    end

    def balance_currencies
      notional_balances.body.sort_by(&:currency)
    end

    def balance_table_row(balance)
      [
        balance.currency,
        "#{humanize_number(balance.amount)} (#{humanize_number(balance.amountNotional)})",
        "#{humanize_number(balance.available)} (#{humanize_number(balance.availableNotional)})"
      ]
    end
  end
end
