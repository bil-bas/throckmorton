module Game
  class Map < BasicGameObject
    MINI_SCALE = 1 / 2.0
    LIGHTING_SCALE = 1 # Number of lighting cells in a tile.
    NO_LIGHT_COLOR = Color.rgba(70, 70, 70, 255) # Colour outside range of lighting.

    attr_reader :grid_width, :grid_height, :width, :height
    attr_reader :lighting_overlay

    LIGHTING_UPDATE_INTERVAL = 1 / 10.0
     
    def initialize
      super()
    end

    def generate
      maker = WorldMaker.new

      tile_data = maker.generate_tile_data 33, 27
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
    end

    def create_objects_from_data(data)
      t = Time.now
      data.each do |class_name, x, y, type|
        klass = Game.const_get class_name
        #raise class_name unless [Item, Enemy].any? {|c| klass.is_a? c }

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

        parent.objects.find_all {|o| o.is_a?(Entity) && o.type == :fire_beetle }.each do |object|
          object.illuminate viewer, @lighting_overlay, range: 1
        end
      end
    end

    def tile_at_grid(x, y)
      return nil if x < 0 or y < 0
      @tiles[y][x] rescue nil
    end

    def tile_at_coordinate(x, y)
      tile_at_grid x / Tile::WIDTH.to_f + 0.5, y / Tile::WIDTH.to_f + 0.5
    end

    def reveal(tile)
      if parent.client?
        @revealed_overlay.set_pixel tile.grid_x, tile.grid_y, color: :alpha
      end
    end
    
    def draw
      @background ||= $window.record(width, height) do
        t = Time.now
        @tiles.each do |row|
          $window.translate -Tile::WIDTH / 2, -Tile::WIDTH / 2 do
            $window.scale 2 do
              row.each {|t| t.draw }
            end
          end
        end
        info "Recorded tile map in #{((Time.now - t).to_f * 1000).to_i}ms"
      end

      @background.draw 0, 0, ZOrder::TILES

      draw_lighting
    end

    def draw_mini
      @background.draw 0, 0, ZOrder::TILES
      draw_lighting
    end

    def draw_lighting
      $window.translate -Tile::WIDTH / 2, -Tile::WIDTH / 2 do
        @revealed_overlay.draw 0, 0, ZOrder::LIGHT, Tile::WIDTH, Tile::WIDTH
        lighting_overlay.draw 0, 0, ZOrder::LIGHT, Tile::WIDTH / LIGHTING_SCALE, Tile::WIDTH / LIGHTING_SCALE,
                              Color::WHITE, :multiply
      end
    end

    # Fill with mobs and objects.

  end
end