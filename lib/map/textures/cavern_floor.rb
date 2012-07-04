require_relative "texture"

module Game
  module Textures
    class CavernFloor < Texture
      FRAMES = 1
      COLOR = [0.2, 0.3, 0.3] # Gosu::Color.rgb(60, 80, 100)

      protected
      def create_generators
        @midi = Perlin::Generator.new 128, 0.5, 1
        @macro = Perlin::Generator.new 35, 0.5, 1
        @micro = Perlin::Generator.new 145, 0.5, 1
        @moss = Perlin::Generator.new 123, 0.5, 1
      end

      protected
      def generate_noises(x, y, steps_x, steps_y)
        @micro_noise =  @micro.chunk x, y, steps_x, steps_y, 0.5
        @midi_noise = @midi.chunk x, y, steps_x, steps_y, 0.03
        @macro_noise = @macro.chunk x, y, steps_x, steps_y, 0.007
        @moss_noise = @moss.chunk x, y, steps_x, steps_y, 0.05
      end

      protected
      def color(x, y)
        color = COLOR.map do |c|
          c + @micro_noise[x][y] * 0.03 +
              @midi_noise[x][y] * 0.04 * -@macro_noise[x][y] +
              @macro_noise[x][y] * 0.05
        end

        if @moss_noise[x][y] < @macro_noise[x][y] - 0.4
          color[1] -= @moss_noise[x][y] * 0.1
        end

        color
      end
    end
  end
end