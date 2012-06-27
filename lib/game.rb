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
  TILES, PROJECTILES, ITEM, ENEMY, PLAYER, LIGHT, GUI, CURSOR = *(0..100)
end

t = Time.now

require_relative "standard_ext/class"
require_relative "chipmunk_ext/space"
require_relative "chingu_ext/game_object"

require_relative "window"

require_relative "states/play"

require_relative "map/map"
require_relative "map/tile"

require_relative "mixins/line_of_sight"

require_relative "objects/physics_object"
require_relative "objects/item"

require_relative "objects/player"
require_relative "objects/health_path"
require_relative "objects/energy_pack"
require_relative "objects/enemy"
require_relative "objects/projectile"
require_relative "objects/treasure"

puts "Loaded scripts in #{Time.now - t}s"

Game::Window.new.show