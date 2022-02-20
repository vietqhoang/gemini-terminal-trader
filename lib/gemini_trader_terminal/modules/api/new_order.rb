# frozen_string_literal: true

module Api
  module NewOrder
    private

    attr_accessor :new_order

    def populate_new_order(**parameters)
      self.new_order = api.post.new_order(**parameters)
    end
    alias submit_new_order populate_new_order
  end
end
