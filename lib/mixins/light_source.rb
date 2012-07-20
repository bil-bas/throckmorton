module Game
module Mixins
  # A source of illumination.
  module LightSource
    attr_reader :illumination_range, :light
    def illuminating?; !@illumination_range.nil?; end

    def initialize(options = {})
      options = {
          illumination_range: nil, # Can be overridden when illuminating.
      }.merge! options

      @illumination_range = options[:illumination_range]

      super options
    end

    def draw
      # TODO: Draw a circle of light?
      super
    end
  end
end
end