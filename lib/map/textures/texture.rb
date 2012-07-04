module Game
  module Textures
    class Texture
      ANIMATION_FRAMES = 5

      def num_frames; self.class::ANIMATED ? ANIMATION_FRAMES : 1 end

      def initialize
        create_generators
      end

      def render(frames, x, y, width, height)
        frames = [frames] unless frames.is_a? Enumerable
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
      # Time parameter only used on animated textures.
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
                   sync_mode: :no_sync,
                   color_control: lambda {|_, pixel_x, pixel_y|
                     color pixel_x - x, pixel_y - y # Noise index.
                   }

        nil
      end

      alias_method :[], :color
    end
  end
end