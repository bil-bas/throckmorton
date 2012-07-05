require_relative "texture"

module Game
  module Textures
    class Water < Texture
      ANIMATED = true
      COLOR = [0.25, 0.45, 0.6]

      WATER_STEP = 0.2
      ROCK_STEP = 0.6

      protected
      def create_generators(seed)
        @ripples = Perlin::Generator.new seed, 0.5, 1
        @rock = Perlin::Generator.new seed, 0.5, 1
      end

      protected
      def generate_noises(x, y, steps_x, steps_y, time = 0)
        @ripple_noise = @ripples.chunk x * WATER_STEP, y * WATER_STEP, time * 0.2, steps_x, steps_y, 1, WATER_STEP
        @rock_noise = @rock.chunk x * ROCK_STEP, y * ROCK_STEP, steps_x, steps_y, ROCK_STEP
      end

      protected
      def color(x, y)
        color = COLOR.map {|c| c + @ripple_noise[x][y].first * 0.02 }

        color[1] += @rock_noise[x][y] * 0.05
        color[2] += @rock_noise[x][y] * 0.1

        color
      end
    end
  end
end