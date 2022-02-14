require_relative 'base'
require_relative 'modules/api/balances'
require_relative 'modules/api/new_order'
require_relative 'modules/api/notional_volume'
require_relative 'modules/api/symbol_details'
require_relative 'modules/api/ticker'
require_relative 'modules/quote_currency_pair_chart'

module GeminiTraderTerminal
  class ExchangeBuyOrder < Base
    include Api::Balances
    include Api::NewOrder
    include Api::NotionalVolume
    include Api::SymbolDetails
    include Api::Ticker
    include QuoteCurrencyPairChart

    def initialize(**attributes)
      super

      prompt_buy_order
    end

    private

    attr_accessor :base_currency, :limit_price, :order_purchase_amount, :order_fee_amount, :order_total_amount, :quote_currency

    def prompt_buy_order
      populate_quote_currency_pair_chart(balance_currencies)
      prompt_quote_currency

      return quote_currency_available_balance_not_positive_pathway unless available_balance_for_currency(quote_currency).positive?

      prompt_base_currency
      populate_currency_pair(quote_currency, base_currency)
      populate_currency_pair_details(currency_pair)

      return currency_pair_not_open_for_trade_pathway unless currency_pair_available_for_trade?(currency_pair_details)

      populate_ticker(currency_pair)
      refresh_notional_balances
      populate_notional_volume
      display_ticker
      display_quote_currency_available_balance
      display_notional_volume
      prompt_order_total_amount

      return order_total_amount_is_less_than_available_balance_pathway if available_balance_for_currency(quote_currency) < order_total_amount

      refresh_ticker(currency_pair)
      prompt_limit_price
      calculate_itemize_amounts

      return order_purchase_amount_is_less_than_minimum_order_size_pathway if order_purchase_base_currency_amount < base_currency_minimum_order_size

      display_order_preview

      return cancel_order_pathway unless prompt_submit_order

      submit_new_order(
        symbol: currency_pair,
        amount: order_purchase_base_currency_amount.to_s,
        price: limit_price.to_s,
        side: 'buy',
        type: 'exchange limit',
        options: ['maker-or-cancel']
      )

      return display_new_order_error if new_order.body.result == 'error'

      display_new_order
    end

    def prompt_quote_currency
      self.quote_currency =
        prompt.select(
          'What currency would you like to use for the trade?',
          quote_currency_pair_chart.keys,
          filter: true,
          per_page: 8
        )
    end

    def quote_currency_available_balance_not_positive_pathway
      prompt_say_alert("Your available balance for the quote currency `#{quote_currency}` is insufficient to continue with the trade.")
    end

    def prompt_base_currency
      self.base_currency =
        prompt.select(
          'What would you like to trade for?',
          quote_currency_pair_chart[quote_currency].keys.sort,
          filter: true,
          per_page: 8
        )
    end

    def currency_pair_not_open_for_trade_pathway
      prompt_say_alert("The status for the trading pair `#{currency_pair}` is `#{currency_pair_details.body.status}`. Support for the trade is not available on Gemini or supported by this terminal.")
    end

    def display_ticker
      prompt_say_table do |table|
        table.title = "`#{currency_pair}` ticker as of #{Time.at(ticker.body.volume.timestamp/1000).utc}"
        table.add_row ["Bid (#{quote_currency.upcase})", humanize_number(ticker.body.bid)]
        table.add_row ["Ask (#{quote_currency.upcase})", humanize_number(ticker.body.ask)]
        table.add_row ["Last (#{quote_currency.upcase})", humanize_number(ticker.body.last)]
      end
    end

    def display_quote_currency_available_balance
      prompt_say_table do |table|
        table.title = "Available `#{quote_currency.upcase}` balance for order as of #{notional_balances.response_at.iso8601}"
        table.add_row [humanize_number(available_balance_for_currency(quote_currency))]
      end
    end

    def display_notional_volume
      prompt_say_table do |table|
        table.title = "API fee as of #{notional_volume.response_at.iso8601}"
        table.add_row ['Maker fee (bps)', notional_volume.body.api_maker_fee_bps]
        table.add_row ['Taker fee (bps)', notional_volume.body.api_taker_fee_bps]
        table.add_row ['Auction fee (bps)', notional_volume.body.api_auction_fee_bps]
      end
    end

    def prompt_order_total_amount
      self.order_total_amount = adjust_precision(prompt.ask("How much #{quote_currency.upcase} would you like to use on the trade, including fees?", convert: :float), currency_pair_details.body.quote_increment)
    end

    def order_total_amount_is_less_than_available_balance_pathway
      prompt_say_alert("The available balance of #{available_balance_for_currency(quote_currency)} #{quote_currency.upcase} is not enough to cover the trade.")
    end

    def prompt_limit_price
      options = prompt_limit_price_options

      self.limit_price =
        prompt.select(
          "Select the limit price to be used for the trade (#{quote_currency.upcase})",
          options,
          per_page: options.size
        )
    end

    def prompt_limit_price_options
      latest_order_price = ticker.body.last.to_f
      options = [
        { percentage: 1, label: 'latest order price'},
        { percentage: 0.9999, label: '-0.01%'},
        { percentage: 0.9995, label: '-0.05%'},
        { percentage: 0.9990, label: '-0.1%'},
        { percentage: 0.9950, label: '-0.5%'},
        { percentage: 0.9900, label: '-1%'},
        { percentage: 0.9500, label: '-5%'}
      ]

      options.each_with_object({}) do |option, hash|
        limit_price = adjust_precision(latest_order_price * option[:percentage], currency_pair_details.body.quote_increment)

        hash["#{limit_price} (#{option[:label]})"] = limit_price
      end
    end

    def calculate_itemize_amounts
      taker_fee_bps = notional_volume.body.api_taker_fee_bps/(100**2).to_f

      self.order_fee_amount = adjust_precision(order_total_amount * taker_fee_bps, currency_pair_details.body.quote_increment)
      self.order_purchase_amount = adjust_precision(order_total_amount - order_fee_amount, currency_pair_details.body.quote_increment)
    end

    def order_purchase_base_currency_amount
      adjust_precision(order_purchase_amount / limit_price.to_f, currency_pair_details.body.tick_size)
    end

    def base_currency_minimum_order_size
      currency_pair_details.body.min_order_size.to_f
    end

    def order_purchase_amount_is_less_than_minimum_order_size_pathway
      prompt_say_alert("The order purchase amount #{order_purchase_amount} #{quote_currency.upcase} equates to #{order_purchase_base_currency_amount} #{base_currency.upcase}. This is below the minimum order size of #{base_currency_minimum_order_size} #{base_currency.upcase}.")
    end

    def display_order_preview
      prompt_say_table do |table|
        table.title = "Order preview as of #{Time.now.utc.iso8601}"
        table.add_row ['Starting currency', quote_currency.upcase]
        table.add_row ['Ending currency', base_currency.upcase]
        table.add_row ['Trading symbol', currency_pair]
        table.add_row ['Ticker last transaction (USD)', humanize_number(ticker.body.last)]
        table.add_row ["Limit (#{quote_currency.upcase})", humanize_number(limit_price)]
        table.add_row ["Base Purchase (#{quote_currency.upcase})", humanize_number(order_purchase_amount)]
        table.add_row ["Base Purchase (#{base_currency.upcase})", humanize_number(order_purchase_base_currency_amount)]
        table.add_row ["Fee (#{quote_currency.upcase})", humanize_number(order_fee_amount)]
        table.add_row ["Total (#{quote_currency.upcase})", humanize_number(order_total_amount)]
        table.add_row ["#{quote_currency.upcase} balance after trade", humanize_number(adjust_precision(available_balance_for_currency(quote_currency) - order_total_amount, currency_pair_details.body.quote_increment))]
        table.add_separator
        table.add_row [{ value: 'Data generated are estimated and time dependent. Completed order may differ.', colspan: 2, alignment: :center }]
      end
    end

    def prompt_submit_order
      prompt.select(
        "Submit order? There'll be no going back...",
        { 'Yes' => true, 'Cancel' => false },
        convert: :boolean
      )
    end

    def cancel_order_pathway
      prompt_say_alert('The order was canceled and not submitted.')
    end

    def display_new_order_error
      prompt_say_alert("#{new_order.body.reason}—#{new_order.body.message} (HTTP CODE #{new_order.code})")
    end

    def display_new_order
      prompt_say_table do |table|
        table.title = "New order received at #{Time.at(new_order.body.timestampms).utc.iso8601}"
        table.add_row ['Order ID', new_order.body.order_id]
        table.add_row ['Currency pair', new_order.body.symbol]
        table.add_row ['Exchange', new_order.body.exchange]
        table.add_row ['Average Execution Price', new_order.body.avg_execution_price == '0.00' ? '(Order has not executed yet)' : new_order.body.avg_execution_price]
        table.add_row ['Side', new_order.body.side]
        table.add_row ['Type', [new_order.body.type, *new_order.body.options].join(', ')]
        table.add_row ['Active on the books?', new_order.body.is_live ? 'Yes' : 'No']
        table.add_row ['Canceled?', new_order.body.is_cancelled ? 'Yes' : 'No']
        table.add_row ["Limit price (#{quote_currency.upcase})", humanize_number(new_order.body.price)]
        table.add_row ["Original Base Purchase (#{base_currency.upcase})", new_order.body.original_amount]

        table.add_separator
        table.add_row ["It is recommended to check the order on Gemini's website to make sure the order is correct."]
      end
    end
  end
end
