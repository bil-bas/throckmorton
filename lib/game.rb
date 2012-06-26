t = Time.now

require 'bundler/setup'

require 'gosu'
require 'chingu'
require 'texplay'
#require 'fidgit'
require 'chipmunk'

puts "Loaded gems in #{Time.now - t}s"

include Gosu
include Chingu

module ZOrder
  TILES, PROJECTILES, PLAYER = *(0..100)
end

t = Time.now

require_relative "standard_ext/class"
require_relative "chipmunk_ext/space"
require_relative "chingu_ext/game_object"

require_relative "window"

require_relative "states/play"

require_relative "map/map"
require_relative "map/tile"

require_relative "objects/physics_object"
require_relative "objects/player"
require_relative "objects/enemy"
require_relative "objects/projectile"

puts "Loaded scripts in #{Time.now - t}s"

Game::Window.new.show