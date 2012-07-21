require_relative "texture"

module Game
  module Textures
    class Water < Texture
      ANIMATED = true

      class << self
        def color; Gosu::Color.rgb(0, 0, 200) end
      end
    end
  end
end