require_relative "texture"

module Game
  module Textures
    class CavernWall < Texture
      FRAMES = 1
      COLOR = [0.2, 0.1, 0.05] #Gosu::Color.rgb(60, 30, 10)

      protected
      def create_generators
        @generator = Perlin::Generator.new 12, 1, 2
      end

      protected
      def generate_noises(x, y, steps_x, steps_y)
        @noise = @generator.chunk x, y, steps_x, steps_y, 2
      end

      protected
      def color(x, y)
        COLOR.map {|c| c + @noise[x][y] * 0.04 }
      end
    end
  end
end