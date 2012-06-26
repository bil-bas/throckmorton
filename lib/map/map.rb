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
          Tile.new x, y
        end
      end
    end
    
    def start_position
      [width / 2, height / 2]
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