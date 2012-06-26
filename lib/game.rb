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
require_relative "play"
require_relative "map"
require_relative "player"
require_relative "projectile"

Game::Window.new.show