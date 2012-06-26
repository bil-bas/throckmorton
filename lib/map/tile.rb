module Game
  class Tile < Chingu::GameObject
    WIDTH = 16

    def seen?; @seen; end
    def blocks_movement?; @blocks_movement; end

    def initialize(grid_x, grid_y)
      @grid_x, @grid_y = grid_x, grid_y

      @seen = true

      color = ([:white] * 20 + [:red] + [:blue] * 10).sample
      case color
        when :white
          @blocks_movement = false
        when :red
          @blocks_movement = false
        when :blue
          @blocks_movement = true
      end

      image = TexPlay.create_image $window, WIDTH, WIDTH, color: color

      super x: grid_x * WIDTH, y: grid_y * WIDTH, zorder: ZOrder::TILES,
            image: image
    end

    def draw
      super if seen?
    end
  end
end