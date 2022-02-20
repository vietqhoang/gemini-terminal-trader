# frozen_string_literal: true

require_relative 'base'
require_relative 'balances'
require_relative 'exchange_buy_order'
module GeminiTraderTerminal
  # Interactive terminal for main menu options
  class MainMenu < Base
    def initialize(**attributes)
      super

      prompt_main_menu
    end

    private

    def prompt_main_menu
      case prompt.select('What would you like to do?', main_menu_options)
      when :view_balances then view_balances_pathway
      when :exchange_buy_order then exchange_buy_order_pathway
      when :end_session then end_session_pathway
      end
    end
    alias return_to_main_menu prompt_main_menu

    def main_menu_options
      {
        'View balances' => :view_balances,
        'Make an exchange buy limit `maker-or-cancel` trade' => :exchange_buy_order,
        'End session' => :end_session
      }.freeze
    end

    def view_balances_pathway
      GeminiTraderTerminal::Balances.new(environment: environment, default_fiat_currency: default_fiat_currency)
      return_to_main_menu
    end

    def exchange_buy_order_pathway
      GeminiTraderTerminal::ExchangeBuyOrder.new(environment: environment, default_fiat_currency: default_fiat_currency)
      return_to_main_menu
    end

    def end_session_pathway
      prompt_say_message('Goodbye!')
    end
  end
end
