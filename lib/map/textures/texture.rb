module Game
  module Textures
    class Texture
      def initialize
        create_generators
      end

      def render(frame, x, y, width, height)
        generate_noises x, y, width, height

        rect frame, x, y, width, height
      end

      def render_animation(frames, x, y, width, height)
        frames.each_with_index do |frame, time|
          generate_noises x, y, width, height, time
          rect frame, x, y, width, height
        end
      end

      protected
      def create_generators
        raise NotImplementedError
      end

      protected
      def generate_noises(x, y, width, height, time = 0)
        raise NotImplementedError
      end

      protected
      def color(x, y)
        raise NotImplementedError
      end

      protected
      def rect(frame, x, y, width, height)
        frame.rect x, y, x + width - 1, y + height - 1, fill: true,
                   color_control: lambda {|_, pixel_x, pixel_y|
                     color pixel_x - x, pixel_y - y # Noise index.
                   }

        nil
      end

      alias_method :[], :color
    end
  end
end