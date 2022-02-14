module Api
  module Balances
    private

    attr_accessor :notional_balances

    def populate_notional_balances
      self.notional_balances = api.post.notional_balances(default_fiat_currency.to_s)
    end
    alias_method :refresh_notional_balances, :populate_notional_balances

    def available_balance_for_currency(currency)
      refresh_notional_balances

      (notional_balances.body.find { |balance| balance.currency.downcase == currency }&.available || 0).to_f
    end

    def balance_currencies
      refresh_notional_balances

      notional_balances.body.collect(&:currency).map(&:downcase).sort
    end
  end
end
