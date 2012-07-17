require_relative "texture"

module Game
  module Textures

    class Lava < Texture
      ANIMATED = true

      class << self
        def color; Gosu::Color.rgb(200, 25, 0) end
      end
    end
  end
end