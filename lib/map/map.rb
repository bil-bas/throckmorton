module Game
  class Map < BasicGameObject
    MINI_SCALE = 1 / 4.0
    LIGHTING_SCALE = 1 # Number of lighting cells in a tile.
    NO_LIGHT_COLOR = Color.rgba(90, 90, 90, 255) # Colour outside range of lighting.

    attr_reader :grid_width, :grid_height, :width, :height, :tiles
    attr_reader :lighting_overlay

    LIGHTING_UPDATE_INTERVAL = 1 / 10.0
     
    def initialize
      super()
    end

    def generate
      maker = WorldMaker.new

      tile_data = maker.generate_tile_data 50, 50 # Largest, at 200x200, is 50, 50
      create_tiles_from_data tile_data

      object_data = maker.generate_object_data @tiles
      create_objects_from_data object_data
      # TODO: send tile data to players.

      create_lighting if parent.client?

      Messages::CreateMap.broadcast tile_data, object_data
    end

    def create_lighting
      @revealed_overlay = TexPlay.create_image $window, grid_width, grid_height, color: Color.rgba(0, 0, 0, 255)
      @lighting_overlay = TexPlay.create_image $window, grid_width * LIGHTING_SCALE, grid_height * LIGHTING_SCALE
    end

    # Create tiles from tile data (2d array of types - strings or )
    def create_tiles_from_data(data)
      t = Time.now

      @tiles_by_type = Hash.new {|h, k| h[k] = [] }
      @tiles = data.map.with_index do |row, y|
        row.map.with_index do |type, x|
          tile = Tile.new self, x, y, type.to_sym
          @tiles_by_type[type] << tile
          tile
        end
      end

      @grid_width, @grid_height = @tiles[0].size, @tiles.size
      @width, @height = grid_width * Tile::WIDTH, grid_height * Tile::WIDTH

      info "Creating map #{grid_width}x#{grid_height} (#{width}x#{height} pixels)"
      info "Tiles created in #{((Time.now - t).to_f * 1000).to_i}ms"

      render_tiles
    end

    def render_tiles
      t = Time.now

      @static_layer = begin
        image = TexPlay.create_image $window, 200, 200, color: :black

        $window.render_to_image image do
          @tiles_by_type[:wall].each do |tile|
            $window.clip_to tile.x * Tile::SCALE, tile.y * Tile::SCALE,
                            Tile::SPRITE_WIDTH, Tile::SPRITE_WIDTH do
              Image["textures/#{tile.type}_0.png"].draw 0, 0, 0
            end
          end

          @tiles_by_type[:rocks].each do |tile|
            tile.draw
          end
        end
        image.refresh_cache
        image.clear dest_select: :black

        image
      end

      animated_layers = 5.times.map do |frame|
        image = TexPlay.create_image $window, 200, 200, color: :black

        $window.render_to_image image do
          (@tiles_by_type[:lava] + @tiles_by_type[:water]).each do |tile|
            $window.clip_to tile.x * Tile::SCALE, tile.y * Tile::SCALE,
                            Tile::SPRITE_WIDTH, Tile::SPRITE_WIDTH do
              Image["textures/#{tile.type}_#{frame}.png"].draw 0, 0, 0
            end
          end
        end
        image.refresh_cache
        image.clear dest_select: :black

        image
      end
      @animated_layers = (1..(animated_layers.size - 2)).each.with_object [] do |frame, frames|
        frames.unshift << animated_layers[frame]
      end

      info "Rendered tile map in #{((Time.now - t).to_f * 1000).to_i}ms"
    end

    def create_objects_from_data(data)
      t = Time.now
      data.each do |class_name, x, y, type|
        klass = Game.const_get class_name

        if type
          # Type will be a string if it has been serialized.
          parent.add_object klass.new(type.to_sym, x, y)
        else
          parent.add_object klass.new(x, y)
        end
      end
      info "Objects created in #{((Time.now - t).to_f * 1000).to_i}ms"
    end

    def update
      update_lighting if parent.client?
    end

    def update_lighting
      @duration_until_lighting_update ||= LIGHTING_UPDATE_INTERVAL
      @duration_until_lighting_update -= parent.frame_time
      if @duration_until_lighting_update <= 0
        @duration_until_lighting_update += LIGHTING_UPDATE_INTERVAL

        @lighting_overlay.clear color: NO_LIGHT_COLOR

        viewer = parent.player
        parent.player.illuminate viewer, @lighting_overlay

        # TODO: Should be illuminated by config (range and brightness and colour).
        # TODO: All these "static" tile's brightness should be pre-calculated!
        @tiles_by_type[:lava].each do |tile|
          tile.illuminate viewer, @lighting_overlay, range: 2
        end

        parent.objects.find_all {|o| o.illuminating? }.each do |object|
          object.illuminate viewer, @lighting_overlay
        end
      end
    end

    def tile_at_grid(x, y)
      return nil if x < 0 || y < 0
      @tiles[y][x] rescue nil
    end

    def tile_at_coordinate(x, y)
      return nil if x < 0 || y < 0
      @tiles[y.fdiv(Tile::WIDTH) + 0.5][x.fdiv(Tile::WIDTH) + 0.5]
    end

    def reveal(tile)
      if parent.client?
        @revealed_overlay.set_pixel tile.grid_x, tile.grid_y, color: :alpha
      end
    end
    
    def draw
      $window.scale 32 * Tile::SCALE do
        $window.translate 0, 0 do
          Image["textures/floor_0.png"].draw 0, 0, ZOrder::TILES, 2, 2
          @static_layer.draw -4, -4, ZOrder::TILES, 2, 2
          @animated_layers[(milliseconds / 250) % @animated_layers.size].draw -4, -4, ZOrder::TILES, 2, 2
        end
      end

      draw_lighting
    end

    def draw_mini
      $window.translate -Tile::SPRITE_WIDTH / 2, -Tile::SPRITE_WIDTH / 2 do
        $window.scale Tile::SCALE * 64 do
          Image["textures/floor_0.png"].draw 0, -4, ZOrder::TILES
          @static_layer.draw 0, 0, ZOrder::TILES
          @animated_layers.first.draw 0, 0, ZOrder::TILES # Don't animate on the map.
        end
      end

      draw_lighting
    end

    def draw_lighting
      $window.translate -Tile::WIDTH / 2, -Tile::WIDTH / 2 do
        @revealed_overlay.draw 0, 0, ZOrder::LIGHT, Tile::WIDTH, Tile::WIDTH
        lighting_overlay.draw 0, 0, ZOrder::LIGHT, Tile::WIDTH / LIGHTING_SCALE, Tile::WIDTH / LIGHTING_SCALE,
                              Color::WHITE, :multiply
      end
    end
  end
end