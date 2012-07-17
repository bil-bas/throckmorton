require_relative "texture"

module Game
  module Textures
    class CavernWall < Texture
      ANIMATED = false

      class << self
        def color; Gosu::Color.rgb(30, 60, 60) end
      end
    end
  end
end