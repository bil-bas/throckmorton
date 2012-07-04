require_relative "texture"

module Game
  module Textures

    class Lava < Texture
      FRAMES = 5
      COLOR = [0.8, 0.1, 0] #Gosu::Color.rgb(200, 25, 0)

      protected
      def create_generators
        @lava = Perlin::Generator.new 34525, 0.4, 1
        @crust = Perlin::Generator.new 123, 0.8, 4
      end

      protected
      def generate_noises(x, y, steps_x, steps_y, time = 0)
        @crust_noise = @crust.chunk x, y, steps_x, steps_y, 0.2 if time == 0
        @lava_noise = @lava.chunk x, y, time * 0.1, steps_x, steps_y, 1, 0.2
      end

      protected
      def color(x, y)
        if @crust_noise[x][y] > 0.15
          # Dark floating "crust".
          height = 0.2 - @crust_noise[x][y] * 0.3
          [height, height / 2, height / 4]
        else
          # Lava: Glow from below.
          height = @lava_noise[x][y][0]
          [COLOR[0] - height * 0.1, COLOR[1] - height * 0.2, COLOR[2] + height * 0.02]
        end
      end
    end
  end
end