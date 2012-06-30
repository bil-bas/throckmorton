module Game
  class Map < BasicGameObject
    MINI_SCALE = 1 / 2.0
    LIGHTING_SCALE = 1 # Number of lighting cells in a tile.
    NO_LIGHT_COLOR = Color.rgba(70, 70, 70, 255) # Colour outside range of lighting.

    attr_reader :grid_width, :grid_height, :width, :height
    attr_reader :lighting_overlay

    LIGHTING_UPDATE_INTERVAL = 1 / 10.0
     
    def initialize(grid_width, grid_height = grid_width)
      @width, @height = grid_width * Tile::WIDTH, grid_height * Tile::WIDTH

      info "Creating map #{grid_width}x#{grid_height} (#{@width}x#{@height} pixels)"
      t = Time.now
      @grid_width, @grid_height = grid_width, grid_height

      @tiles_by_type = Hash.new {|h, k| h[k] = [] }

      @tiles = grid_height.times.map do |y|
        grid_width.times.map do |x|
          if x == 0 || y == 0 || x == @grid_width - 1 || y == @grid_height - 1
            type = :wall
          elsif distance(x, y, @grid_width / 2, @grid_height / 2) < 5
            type = ([:floor] * 10 + [:water]).sample
          else
            type = ([:floor] * 40 + [:water] * 2 + [:rocks] + [:lava] + [:wall] * 16).sample
          end

          tile = Tile.new self, x, y, type
          @tiles_by_type[type] << tile
          tile
        end
      end

      @revealed_overlay = TexPlay.create_image $window, @grid_width, @grid_height, color: Color.rgba(0, 0, 0, 255)
      @lighting_overlay = TexPlay.create_image $window, @grid_width * LIGHTING_SCALE, @grid_height * LIGHTING_SCALE

      info "Map created in #{((Time.now - t).to_f * 1000).to_i}ms"

      super()
    end

    def update
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
      end
    end

    def tile_at_grid(x, y)
      return nil if x < 0 or y < 0
      @tiles[y][x] rescue nil
    end

    def tile_at_coordinate(x, y)
      tile_at_grid x / Tile::WIDTH.to_f + 0.5, y / Tile::WIDTH.to_f + 0.5
    end
    
    def start_position
      [width / 2, height / 2]
    end

    def reveal(tile)
      @revealed_overlay.set_pixel tile.grid_x, tile.grid_y, color: :alpha
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
    def populate
      player_position = start_position
      @tiles.flatten.select {|t| t.spawn_object? && distance(t.x, t.y, *player_position) > 20 }.each do |tile|
        case rand(100)
          when 0..10
            @@possibilities ||= Enemy.config.map {|k, v| [k] * v[:frequency] }.flatten
            parent.add_object Enemy.new(@@possibilities.sample, tile.x, tile.y)

          when 15..17
            parent.add_object HealthPack.new(tile.x, tile.y)
          when 18
            parent.add_object EnergyPack.new(tile.x, tile.y)
          when 20..26
            parent.add_object Treasure.new(tile.x, tile.y)
        end
      end
    end
  end
end