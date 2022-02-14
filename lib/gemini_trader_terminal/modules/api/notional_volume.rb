module Api
  module NotionalVolume
    private

    attr_accessor :notional_volume

    def populate_notional_volume
      self.notional_volume = api.post.notional_volume
    end
    alias_method :refresh_notional_volume, :populate_notional_volume
  end
end
