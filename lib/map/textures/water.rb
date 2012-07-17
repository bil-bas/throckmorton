require_relative "texture"

module Game
  module Textures
    class Water < Texture
      ANIMATED = true

      class << self
        def color; Gosu::Color.rgb(40, 110, 140) end
      end
    end
  end
end