# frozen_string_literal: true

require_relative 'base'
require_relative 'modules/api/balances'

module GeminiTraderTerminal
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
        table.title = "Account balance as of #{notional_balances.response_at.iso8601} for #{environment} environment"
        table.headings = ['Currency', "Amount (#{default_fiat_currency.upcase} equivalent)", "Available for trade (#{default_fiat_currency.upcase} equivalent)"]

        notional_balances.body.sort_by(&:currency).each do |balance|
          table.add_row [balance.currency, "#{humanize_number(balance.amount)} (#{humanize_number(balance.amountNotional)})", "#{humanize_number(balance.available)} (#{humanize_number(balance.availableNotional)})"]
        end
      end
    end
  end
end
