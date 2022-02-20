# frozen_string_literal: true

require_relative 'concerns/currencyable'
require_relative 'concerns/environmentable'
require_relative 'concerns/terminalable'
require_relative 'gemini_trader_terminal/main_menu'

# Entry point class to load the interactive terminal client
class ApplicationTerminal
  include Currencyable
  include Environmentable
  include Terminalable

  def initialize
    populate_terminalable
    prompt_select_environment
    prompt_select_default_fiat_currency
    initialize_gemini_trader_terminal_main_menu
  end

  private

  def initialize_gemini_trader_terminal_main_menu
    GeminiTraderTerminal::MainMenu.new(environment: environment, default_fiat_currency: default_fiat_currency)
  end

  def prompt_select_environment
    self.environment = prompt.select('What Gemini environment would you like to use?', ENVIRONMENTS)
  end

  def prompt_select_default_fiat_currency
    self.default_fiat_currency = prompt.select('What default fiat currency would you like to set?', DEFAULT_FIAT_CURRENCIES)
  end
end
