require_relative "texture"

module Game
  module Textures

    class Lava < Texture
      ANIMATED = true
      COLOR = [0.8, 0.1, 0] #Gosu::Color.rgb(200, 25, 0)

      CRUST_STEP = 0.3
      LAVA_STEP = 0.2

      protected
      def create_generators(seed)
        @lava = Perlin::Generator.new seed, 0.4, 1
        @crust = Perlin::Generator.new seed, 0.8, 4
      end

      protected
      def generate_noises(x, y, steps_x, steps_y, time = 0)
        if time == 0
          @crust_noise = @crust.chunk x * CRUST_STEP, y * CRUST_STEP,
                                      steps_x, steps_y, CRUST_STEP
        end
        @lava_noise = @lava.chunk x * LAVA_STEP, y * LAVA_STEP,
                                  time * 0.1,
                                  steps_x, steps_y, 1, 0.2
      end

      protected
      def color(x, y)
        if @crust_noise[x][y] > 0
          # Dark floating "crust".
          height = @crust_noise[x][y]
          [height * 0.5, height * 0.4, height * 0.35]
        else
          # Lava: Glow from below.
          height = @lava_noise[x][y].first
          [COLOR[0] - height * 0.1, COLOR[1] - height * 0.2, COLOR[2] + height * 0.02]
        end
      end
    end
  end
end