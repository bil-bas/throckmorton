require_relative "texture"

module Game
  module Textures
    class CavernFloor < Texture
      ANIMATED = false

      class << self
        def color; Gosu::Color.rgb(20, 70, 75) end
      end
    end
  end
end