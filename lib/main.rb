Config = RbConfig if defined? RbConfig unless defined? RSpec # Hack for deprecation warning.

if $0 == __FILE__
  puts "Run the game using: ruby bin/game_of_scones"
  exit 1
end

require 'forwardable'
require 'fileutils'

APP_NAME = "Game_of_Scones"

USER_DATA_PATH = if ENV['APPDATA']
                   pretty_name = APP_NAME.split("_").map(&:capitalize).join(" ").gsub(/ (?:And|Or|Of) /, &:downcase)
                   File.join ENV['APPDATA'].gsub("\\", "/"), pretty_name
                 else
                   File.expand_path "~/.#{APP_NAME}"
                 end

FileUtils.mkdir_p USER_DATA_PATH

t = Time.now

require 'bundler/setup'
Bundler.require :default

require_relative 'standard_ext/object' # Set up logging

info { "Loaded gems in #{Time.now - t}s" }

include Gosu
include Chingu

# Setup Chingu's autoloading media directories.
media_dir = File.expand_path("../../media", __FILE__)
Image.autoload_dirs.unshift File.join(media_dir, 'images')
Sample.autoload_dirs.unshift File.join(media_dir, 'sounds')
Song.autoload_dirs.unshift File.join(media_dir, 'music')
Font.autoload_dirs.unshift File.join(media_dir, 'fonts')

module ZOrder
  TILES, PROJECTILES, ITEM, ENEMY, PLAYER, LIGHT, PHYSICS, GUI, CURSOR = *(0..100)
end

t = Time.now

if RUBY_VERSION < "1.9.3"
  module Kernel
    alias_method :old_rand, :rand

    def rand(*args)
      if args[0].is_a? Range
        args[0].min + old_rand(args[0].max - args[0].min)
      else
        old_rand *args
      end
    end
  end
end



require_relative "standard_ext/class"
require_relative "chipmunk_ext/space"
require_relative "chingu_ext/game_object"
require_relative "texplay_ext/color"
require_relative "texplay_ext/image"

require_relative "mixins/line_of_sight"
require_relative "mixins/light_source"

require_relative "sprite_sheet"
require_relative "game"
require_relative "version"
require_relative "window"

require_relative "network/client"
require_relative "network/server"

require_relative "states/play"

require_relative "map/textures"

require_relative "map/world_maker"
require_relative "map/map"
require_relative "map/tile"

require_relative "objects/physics_object"
require_relative "objects/item"

require_relative "objects/entity"
require_relative "objects/player"
require_relative "objects/health_pack"
require_relative "objects/energy_pack"
require_relative "objects/enemy"
require_relative "objects/projectile"
require_relative "objects/treasure"

require_relative "messages"

info { "Loaded scripts in #{Time.now - t}s" }