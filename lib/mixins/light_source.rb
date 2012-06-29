module Game
  # A source of illumination.
  module LightSource
    attr_reader :illumination_range

    def initialize(options = {})
      @illumination_range = options[:illumination_range] || raise
      super options
    end

    def illuminate
      calculate_tiles_in_los illumination_range
      update_lighting illumination_range
    end

    protected
    def calculate_tiles_in_los(range)
      map = parent.map

      tile = self.tile
      tile_x, tile_y = tile.grid_x, tile.grid_y
      @visible_tile_positions = Set.new # Store list of [x, y] that are visible.

      ((tile_y - range)..(tile_y + range)).each do |offset_y|
        ((tile_x - range)..(tile_x + range)).each do |offset_x|
          if distance(tile_x, tile_y, offset_x, offset_y) <= range
            tile = map.tile_at_grid offset_x, offset_y
            if tile && line_of_sight?(tile)
              @visible_tile_positions << [tile.grid_x, tile.grid_y]
              tile.seen = true unless tile.seen?
            end
          end
        end
      end
    end

    protected
    def update_lighting(range)

      player_x, player_y = x / Tile::WIDTH, y / Tile::WIDTH
      scale_i = Map::LIGHTING_SCALE
      scale_f = scale_i.to_f
      overlay = parent.map.lighting_overlay
      overlay.circle player_x * scale_i, player_y * scale_i,
                     range * scale_i, fill: true,
                     color_control: lambda {|c, x, y|

                       if @visible_tile_positions.include? [x / scale_i, y / scale_i]
                         # Makes the tile lighter and a bit less red (more cyan).
                         distance = distance(player_x, player_y, x / scale_f, y / scale_f)
                         brightness = 1 - Math::log((2 * distance) / range)
                         [brightness * 0.9, brightness, brightness, 1]
                       else
                         Map::NO_LIGHT_COLOR
                       end
                     }
    end
  end
end