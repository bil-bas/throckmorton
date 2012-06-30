module Game
module Mixins
  # A source of illumination.
  module LightSource
    attr_reader :illumination_range

    def initialize(options = {})
      options = {
          illumination_range: 0, # Can be overridden when illuminating.
      }.merge! options

      @illumination_range = options[:illumination_range]

      @visible_tile_positions = Set.new # Store list of [x, y] that are visible.

      super options
    end

    def illuminate(viewer, overlay, options = {})
      options = {
          range: illumination_range,
      }.merge! options

      tile = is_a?(Tile) ? self : self.tile

      # Doing these calculations is quite costly, so they aren't done every turn.

      # Takes about 2ms
      calculate_tiles_in_los tile, viewer, options[:range]

      # Takes about 1ms
      update_lighting tile, options[:range], overlay
    end

    protected
    def calculate_tiles_in_los(source, viewer, range)
      source_x, source_y = source.grid_x, source.grid_y
      map = parent.map

      @visible_tile_positions.clear

      ((source_y - range)..(source_y + range)).each do |offset_y|
        ((source_x - range)..(source_x + range)).each do |offset_x|
          if distance(source_x, source_y, offset_x, offset_y) <= range
            tile = map.tile_at_grid offset_x, offset_y
            if tile && viewer.line_of_sight?(tile)
              @visible_tile_positions << [tile.grid_x, tile.grid_y]
              tile.seen = true unless tile.seen?
            end
          end
        end
      end
    end

    protected
    def update_lighting(source, range, overlay)
      source_x, source_y = source.x / Tile::WIDTH, source.y / Tile::WIDTH
      scale_i = Map::LIGHTING_SCALE
      scale_f = scale_i.to_f

      overlay.circle source_x * scale_i, source_y * scale_i,
                     range * scale_i, fill: true,
                     color_control: lambda {|c, x, y|
                       if @visible_tile_positions.include? [x / scale_i, y / scale_i]
                         # Makes the tile lighter. Multiple light sources choose the lightest (don't combine).
                         distance = distance(source_x, source_y, x / scale_f, y / scale_f)
                         brightness = [c[0], 1 - Math::log((1.5 * distance) / range)].max
                         [brightness, brightness, brightness, 1]
                       else
                         c || [1, 0, 0, 1] # Give a meaningless colour when outside the image.
                       end
                     }
    end
  end
end
end