module Game
  class Map < Chingu::GameObject
    MINI_SCALE = 1 / 4.0
    TILE_WIDTH = 16
    
    attr_reader :grid_width, :grid_height
     
    def initialize(grid_width, grid_height = grid_width)
      super()
      
      @grid_width, @grid_height = grid_width, grid_height
      
      @tiles = [:white, :red, :blue].map do |color|
        TexPlay.create_image $window, TILE_WIDTH, TILE_WIDTH, color: color
      end
    end
    
    def start_position
      [grid_width * TILE_WIDTH / 2, grid_height * TILE_WIDTH / 2]
    end
    
    def draw
      @background ||= $window.record(@grid_width  * TILE_WIDTH, @grid_height  * TILE_WIDTH) do
        @grid_height.times do |y|
          @grid_width.times do |x|
            @tiles.sample.draw x * TILE_WIDTH, y * TILE_WIDTH, 0 
          end
        end
      end
      
      @background.draw 0, 0, 0 
    end   

    def draw_mini
      @background.draw_rot $window.width / 2, $window.height / 2, 0, 0, 0.5, 0.5
    end    
  end
end