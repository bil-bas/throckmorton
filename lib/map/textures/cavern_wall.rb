require_relative "texture"

module Game
  module Textures
    class CavernWall < Texture
      ANIMATED = false
      COLOR = [0.2, 0.1, 0.05] #Gosu::Color.rgb(60, 30, 10)
      STEP = 2

      protected
      def create_generators
        @generator = Perlin::Generator.new 12, 1, 2
      end

      protected
      def generate_noises(x, y, steps_x, steps_y, time)
        @noise = @generator.chunk x * STEP, y * STEP, steps_x, steps_y, STEP
      end

      protected
      def color(x, y)
        COLOR.map {|c| c + @noise[x][y] * 0.04 }
      end
    end
  end
end