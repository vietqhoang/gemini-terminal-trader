# frozen_string_literal: true

module Currencyable
  DEFAULT_FIAT_CURRENCIES = %i[usd].freeze

  private

  # NOTE: Gemini return's precision (number of decimals) as a float, ie 0.001.
  def adjust_precision(amount, precision_float)
    amount.to_f.floor(translate_to_number_of_digits(precision_float))
  end

  # NOTE:
  # To figure out number of decimal digits, the following identified cases will need to be handled:
  # 1. 0.000000000000001.to_s => "1.0e-15"
  # 2. 0.0001.to_s => "0.0001"
  # 3. 10.to_s => "10"
  def translate_to_number_of_digits(precision_value)
    precision_string = precision_value.to_s

    return precision_string.split('e-').last.to_i if precision_string.include?('e-')
    return precision_string.split('.').last.size if precision_string.start_with?('0.')

    -1 * precision_string.size
  end
end
