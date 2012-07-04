require_relative "texture"

module Game
  module Textures
    class Water < Texture
      ANIMATED = true
      COLOR = [0, 0.25, 0.4] # Gosu::Color.rgb(0, 60, 90)

      WATER_STEP = 0.2

      protected
      def create_generators(seed)
        @generator = Perlin::Generator.new seed, 1, 1
      end

      protected
      def generate_noises(x, y, steps_x, steps_y, time = 0)
        @noise = @generator.chunk x * WATER_STEP, y * WATER_STEP, time * 0.1, steps_x, steps_y, 1, WATER_STEP
      end

      protected
      def color(x, y)
        COLOR[0..2].map {|c| c + @noise[x][y].first * 0.02 }
      end
    end
  end
end