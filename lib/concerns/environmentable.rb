# frozen_string_literal: true

# Sharing common environment related methods and data
module Environmentable
  ENVIRONMENTS = %i[live sandbox].freeze

  private

  attr_accessor :environment
end
