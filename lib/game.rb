require 'gosu'
require 'chingu'
require 'texplay'
#require 'fidgit'

include Gosu
include Chingu

require_relative "window"
require_relative "play"
require_relative "map"
require_relative "player"
require_relative "projectile"

Game::Window.new.show