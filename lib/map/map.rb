module Game
  class Map
    MINI_SCALE = 1 / 4.0
    TILE_WIDTH = 16
    
    attr_reader :grid_width, :grid_height, :width, :height
     
    def initialize(grid_width, grid_height = grid_width)
      @width, @height = grid_height * TILE_WIDTH, grid_width * TILE_WIDTH
      
      @grid_width, @grid_height = grid_width, grid_height
      
      @tiles = grid_height.times.map do |y|
        grid_width.times.map do |x|
          if distance(x, y, @grid_width / 2, @grid_height / 2) < 5
            type = :white
          else
            type = ([:white] * 20 + [:blue] * 10).sample
          end

          Tile.new x, y, type
        end
      end
    end

    def tile_at_grid(x, y)
      return nil if x < 0 or y < 0
      @tiles[y][x] rescue nil
    end

    def tile_at_coordinate(x, y)
      tile_at_grid x / TILE_WIDTH.to_f + 0.5, y / TILE_WIDTH.to_f + 0.5
    end
    
    def start_position
      [width / 2, height / 2]
    end

    def redraw
      @background = nil
    end
    
    def draw
      @background ||= $window.record(width, height) do
        @tiles.each do |row|
          row.each {|t| t.draw }
        end
      end
      
      @background.draw 0, 0, ZOrder::TILES
    end   

    def draw_mini
      @background.draw 0, 0, ZOrder::TILES
    end    
  end
end