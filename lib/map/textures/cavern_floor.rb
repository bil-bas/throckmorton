require_relative "texture"

module Game
  module Textures
    class CavernFloor < Texture
      ANIMATED = false

      class << self
        def color; Gosu::Color.rgb(40, 70, 75) end
      end
    end
  end
end