require_relative "texture"

module Game
  module Textures
    class Water < Texture
      FRAMES = 5
      COLOR = [0, 0.25, 0.4] # Gosu::Color.rgb(0, 60, 90)

      protected
      def create_generators
        @generator = Perlin::Generator.new 99, 1, 1
      end

      protected
      def generate_noises(x, y, steps_x, steps_y, time = 0)
        @noise = @generator.chunk x, y, time * 0.1, steps_x, steps_y, 1, 0.2
      end

      protected
      def color(x, y)
        COLOR[0..2].map {|c| c + @noise[x][y][0] * 0.02 }
      end
    end
  end
end