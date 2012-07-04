require_relative "texture"

module Game
  module Textures
    class CavernFloor < Texture
      ANIMATED = false
      COLOR = [0.2, 0.3, 0.3] # Gosu::Color.rgb(60, 80, 100)

      MICRO_STEP = 0.5
      MIDI_STEP = 0.03
      MACRO_STEP = 0.007
      MOSS_STEP = 0.05

      protected
      def create_generators
        @midi = Perlin::Generator.new 128, 0.5, 1
        @macro = Perlin::Generator.new 35, 0.5, 1
        @micro = Perlin::Generator.new 145, 0.5, 1
        @moss = Perlin::Generator.new 123, 0.5, 1
      end

      protected
      def generate_noises(x, y, steps_x, steps_y, time)
        @micro_noise =  @micro.chunk x * 0.5, y * 0.5,
                                     steps_x, steps_y,
                                     0.5
        @midi_noise = @midi.chunk x * MIDI_STEP, y * MIDI_STEP,
                                  steps_x, steps_y,
                                  MIDI_STEP
        @macro_noise = @macro.chunk x * MACRO_STEP, y * MACRO_STEP,
                                    steps_x, steps_y,
                                    MACRO_STEP
        @moss_noise = @moss.chunk x * MOSS_STEP, y * MOSS_STEP,
                                  steps_x, steps_y,
                                  MOSS_STEP
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