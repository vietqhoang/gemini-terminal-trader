module Humanizeable
  private

  def humanize_number(number_string)
    return '' if number_string.nil?

    whole_number, fractional_number = number_string.to_s.split('.')

    [humanize_integer(whole_number), fractional_number == '0' ? nil : fractional_number].compact.join('.')
  end

  def humanize_integer(integer_string)
    integer_string.reverse.scan(/\d{3}|.+/).join(',').reverse
  end
end
