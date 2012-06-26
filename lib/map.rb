module Game
  class Map < Chingu::GameObject
    MINI_SCALE = 1 / 4.0
    TILE_WIDTH = 16
    
    attr_reader :grid_width, :grid_height, :width, :height
     
    def initialize(grid_width, grid_height = grid_width)
      @width, @height = grid_height * TILE_WIDTH, grid_width * TILE_WIDTH
      
      @grid_width, @grid_height = grid_width, grid_height
      
      @tiles = ([:white] * 20 + [:red] + [:blue] * 10).map do |color|
        TexPlay.create_image $window, TILE_WIDTH, TILE_WIDTH, color: color
      end
      
      super(zorder: ZOrder::TILES)
    end
    
    def start_position
      [width / 2, height / 2]
    end
    
    def draw
      @background ||= $window.record(width, height) do
        @grid_height.times do |y|
          @grid_width.times do |x|
            @tiles.sample.draw x * TILE_WIDTH, y * TILE_WIDTH, 0 
          end
        end
      end
      
      @background.draw 0, 0, zorder 
    end   

    def draw_mini
      @background.draw 0, 0, zorder
    end    
  end
end