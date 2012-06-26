require 'gosu'
require 'chingu'
require 'texplay'
#require 'fidgit'

include Gosu
include Chingu

module ZOrder
  TILES = 0
  PROJECTILES = 1
  PLAYER = 2
end

require_relative "window"
require_relative "states/play"
require_relative "map/map"
require_relative "map/tile"
require_relative "objects/player"
require_relative "objects/projectile"

Game::Window.new.show