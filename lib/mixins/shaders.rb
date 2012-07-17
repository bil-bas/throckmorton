module Game
  module Mixins
    module Shaders
      def fragment_shader(name)
        File.expand_path("../../shaders/#{name}.frag", __FILE__)
      end

      def vertex_shader(name)
        File.expand_path("../../shaders/#{name}.vert", __FILE__)
      end
    end
  end
end