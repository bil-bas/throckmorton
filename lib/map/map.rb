module Game
  class Map < BasicGameObject
    MINI_SCALE = 1 / 4.0
    LIGHTING_SCALE = 1 # Number of lighting cells in a tile.
    NO_LIGHT_COLOR = Color.rgba(0, 0, 0, 210) # Colour outside range of lighting.

    attr_reader :grid_width, :grid_height, :width, :height
    attr_reader :lighting_overlay
     
    def initialize(grid_width, grid_height = grid_width)
      @width, @height = grid_width * Tile::WIDTH, grid_height * Tile::WIDTH

      puts "Creating map #{grid_width}x#{grid_height} (#{@width}x#{@height} pixels)"
      t = Time.now
      @grid_width, @grid_height = grid_width, grid_height
      
      @tiles = grid_height.times.map do |y|
        grid_width.times.map do |x|
          if x == 0 || y == 0 || x == @grid_width - 1 || y == @grid_height - 1
            type = :blue
          elsif distance(x, y, @grid_width / 2, @grid_height / 2) < 5
            type = :white
          else
            type = ([:white] * 20 + [:blue] * 10).sample
          end

          Tile.new self, x, y, type
        end
      end

      @revealed_overlay = TexPlay.create_image $window, @grid_width, @grid_height, color: Color.rgba(0, 0, 0, 255)
      @lighting_overlay = TexPlay.create_image $window, @grid_width * LIGHTING_SCALE, @grid_height * LIGHTING_SCALE

      puts "Map created in #{((Time.now - t).to_f * 1000).to_i}ms"

      super()
    end

    def update
      @lighting_overlay.clear color: NO_LIGHT_COLOR
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
          row.each {|t| t.draw }
        end
        puts "Recorded tile map in #{((Time.now - t).to_f * 1000).to_i}ms"
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
        lighting_overlay.draw 0, 0, ZOrder::LIGHT, Tile::WIDTH / LIGHTING_SCALE, Tile::WIDTH / LIGHTING_SCALE
      end
    end
  end
end