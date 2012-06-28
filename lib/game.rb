Config = RbConfig if defined? RbConfig unless defined? RSpec # Hack for deprecation warning.

t = Time.now

require 'bundler/setup'
Bundler.require :default

require 'forwardable'

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

require_relative "version"
require_relative "window"

require_relative "states/play"

require_relative "map/map"
require_relative "map/tile"

require_relative "mixins/line_of_sight"

require_relative "objects/physics_object"
require_relative "objects/item"

require_relative "objects/entity"
require_relative "objects/player"
require_relative "objects/health_path"
require_relative "objects/energy_pack"
require_relative "objects/enemy"
require_relative "objects/projectile"
require_relative "objects/treasure"

puts "Loaded scripts in #{Time.now - t}s"


module Game
  class << self
    def run(args)
      opts = Slop.parse args, help: true do
        banner "ruby bin#{File::SEPARATOR}game_of_scones [options]\n"

        on :server, 'Create dedicated server'
        on :port, 'UDP port to use', as: :int, default: 7500

        on :v, :version, 'Game version'
      end

      if opts.version?
        puts "Game version: #{VERSION}"

      elsif opts.server?
        raise NotImplementedError
        Server.new.start opts.port

      elsif !opts.help?
        Window.new.show
      end
    end
  end
end