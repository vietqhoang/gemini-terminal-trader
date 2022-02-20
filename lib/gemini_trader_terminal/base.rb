# frozen_string_literal: true

require_relative '../concerns/currencyable'
require_relative '../concerns/environmentable'
require_relative '../concerns/humanizeable'
require_relative '../concerns/terminalable'
require_relative '../gemini_api/get'
require_relative '../gemini_api/post'

module GeminiTraderTerminal
  class Base
    include Currencyable
    include Environmentable
    include Humanizeable
    include Terminalable

    def initialize(**attributes)
      populate_terminalable
      validate_and_assign_environment(attributes[:environment])
      validate_and_assign_default_fiat_currency(attributes[:default_fiat_currency])
      initialize_and_assign_api
    end

    private

    attr_accessor :api, :environment, :default_fiat_currency

    def validate_and_assign_environment(value)
      raise ArgumentError, "Environment must be one of the following: #{ENVIRONMENTS.join(', ')}" unless ENVIRONMENTS.include?(value)

      self.environment = value
    end

    def validate_and_assign_default_fiat_currency(value)
      raise ArgumentError, "Default fiat currency must be one of the following: #{DEFAULT_FIAT_CURRENCIES.join(', ')}" unless DEFAULT_FIAT_CURRENCIES.include?(value)

      self.default_fiat_currency = value
    end

    def initialize_and_assign_api
      self.api =
        OpenStruct.new(
          get: GeminiApi::Get.new(environment: environment),
          post: GeminiApi::Post.new(environment: environment)
        )
    end
  end
end
