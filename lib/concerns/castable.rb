# Type casting helpers
module Castable
  FALSE_VALUES = [
    false, 0,
    '0', :'0',
    'f', :f,
    'F', :F,
    'false', :false,
    'FALSE', :FALSE,
    'off', :off,
    'OFF', :OFF,
  ].to_set.freeze

  private

  # NOTE: https://github.com/rails/rails/blob/main/activemodel/lib/active_model/type/boolean.rb
  def cast_boolean(value)
    return nil if ['', nil].include?(value)

    !FALSE_VALUES.include?(value)
  end
end
