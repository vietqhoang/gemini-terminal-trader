# frozen_string_literal: true

require_relative 'concerns/currencyable'
require_relative 'concerns/environmentable'
require_relative 'concerns/terminalable'
require_relative 'gemini_trader_terminal/main_menu'

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

  attr_accessor :gemini_environment, :gemini_default_fiat_currency

  def initialize_gemini_trader_terminal_main_menu
    GeminiTraderTerminal::MainMenu.new(environment: gemini_environment, default_fiat_currency: gemini_default_fiat_currency)
  end

  def prompt_select_environment
    self.gemini_environment = prompt.select('What Gemini environment would you like to use?', ENVIRONMENTS)
  end

  def prompt_select_default_fiat_currency
    self.gemini_default_fiat_currency = prompt.select('What default fiat currency would you like to set?', DEFAULT_FIAT_CURRENCIES)
  end
end
