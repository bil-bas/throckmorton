module Game
  module Textures
    TYPES = [:cavern_floor, :cavern_wall, :lava, :water]

    TYPES.each do |type|
      require_relative "textures/#{type}"
    end
  end
end